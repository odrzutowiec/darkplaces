/*
	Copyright (C) 2003-2005  Mathieu Olivier

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to:

		Free Software Foundation, Inc.
		59 Temple Place - Suite 330
		Boston, MA  02111-1307, USA

*/


#include "quakedef.h"
#include "snd_main.h"
#include "snd_ogg.h"
#include "snd_wav.h"


/*
=================================================================

  Minimal set of definitions from the Ogg Vorbis lib
  (C) COPYRIGHT 1994-2001 by the XIPHOPHORUS Company
  http://www.xiph.org/

  WARNING: for a matter of simplicity, several pointer types are
  casted to "void*", and most enumerated values are not included

=================================================================
*/

#ifdef _MSC_VER
typedef __int64 ogg_int64_t;
#else
typedef long long ogg_int64_t;
#endif

typedef struct
{
	size_t	(*read_func)	(void *ptr, size_t size, size_t nmemb, void *datasource);
	int		(*seek_func)	(void *datasource, ogg_int64_t offset, int whence);
	int		(*close_func)	(void *datasource);
	long	(*tell_func)	(void *datasource);
} ov_callbacks;

typedef struct
{
	unsigned char	*data;
	int				storage;
	int				fill;
	int				returned;
	int				unsynced;
	int				headerbytes;
	int				bodybytes;
} ogg_sync_state;

typedef struct
{
	int		version;
	int		channels;
	long	rate;
	long	bitrate_upper;
	long	bitrate_nominal;
	long	bitrate_lower;
	long	bitrate_window;
	void	*codec_setup;
} vorbis_info;

typedef struct
{
	unsigned char	*body_data;
	long			body_storage;
	long			body_fill;
	long			body_returned;
	int				*lacing_vals;
	ogg_int64_t		*granule_vals;
	long			lacing_storage;
	long			lacing_fill;
	long			lacing_packet;
	long			lacing_returned;
	unsigned char	header[282];
	int				header_fill;
	int				e_o_s;
	int				b_o_s;
	long			serialno;
	long			pageno;
	ogg_int64_t		packetno;
	ogg_int64_t		granulepos;
} ogg_stream_state;

typedef struct
{
	int			analysisp;
	vorbis_info	*vi;
	float		**pcm;
	float		**pcmret;
	int			pcm_storage;
	int			pcm_current;
	int			pcm_returned;
	int			preextrapolate;
	int			eofflag;
	long		lW;
	long		W;
	long		nW;
	long		centerW;
	ogg_int64_t	granulepos;
	ogg_int64_t	sequence;
	ogg_int64_t	glue_bits;
	ogg_int64_t	time_bits;
	ogg_int64_t	floor_bits;
	ogg_int64_t	res_bits;
	void		*backend_state;
} vorbis_dsp_state;

typedef struct
{
	long			endbyte;
	int				endbit;
	unsigned char	*buffer;
	unsigned char	*ptr;
	long			storage;
} oggpack_buffer;

typedef struct
{
	float				**pcm;
	oggpack_buffer		opb;
	long				lW;
	long				W;
	long				nW;
	int					pcmend;
	int					mode;
	int					eofflag;
	ogg_int64_t			granulepos;
	ogg_int64_t			sequence;
	vorbis_dsp_state	*vd;
	void				*localstore;
	long				localtop;
	long				localalloc;
	long				totaluse;
	void				*reap;  // VOIDED POINTER
	long				glue_bits;
	long				time_bits;
	long				floor_bits;
	long				res_bits;
	void				*internal;
} vorbis_block;

typedef struct
{
	void				*datasource;
	int					seekable;
	ogg_int64_t			offset;
	ogg_int64_t			end;
	ogg_sync_state		oy;
	int					links;
	ogg_int64_t			*offsets;
	ogg_int64_t			*dataoffsets;
	long				*serialnos;
	ogg_int64_t			*pcmlengths;
	vorbis_info			*vi;
	void				*vc;  // VOIDED POINTER
	ogg_int64_t			pcm_offset;
	int					ready_state;
	long				current_serialno;
	int					current_link;
	double				bittrack;
	double				samptrack;
	ogg_stream_state	os;
	vorbis_dsp_state	vd;
	vorbis_block		vb;
	ov_callbacks		callbacks;
} OggVorbis_File;


/*
=================================================================

  DarkPlaces definitions

=================================================================
*/

// Functions exported from the vorbisfile library
static int (*qov_clear) (OggVorbis_File *vf);
static vorbis_info* (*qov_info) (OggVorbis_File *vf,int link);
static int (*qov_open_callbacks) (void *datasource, OggVorbis_File *vf,
								  char *initial, long ibytes,
								  ov_callbacks callbacks);
static int (*qov_pcm_seek) (OggVorbis_File *vf,ogg_int64_t pos);
static ogg_int64_t (*qov_pcm_total) (OggVorbis_File *vf,int i);
static long (*qov_read) (OggVorbis_File *vf,char *buffer,int length,
						 int bigendianp,int word,int sgned,int *bitstream);

static dllfunction_t oggvorbisfuncs[] =
{
	{"ov_clear",			(void **) &qov_clear},
	{"ov_info",				(void **) &qov_info},
	{"ov_open_callbacks",	(void **) &qov_open_callbacks},
	{"ov_pcm_seek",			(void **) &qov_pcm_seek},
	{"ov_pcm_total",		(void **) &qov_pcm_total},
	{"ov_read",				(void **) &qov_read},
	{NULL, NULL}
};

// Handles for the Vorbis and Vorbisfile DLLs
static dllhandle_t vo_dll = NULL;
static dllhandle_t vf_dll = NULL;

typedef struct
{
	unsigned char *buffer;
	ogg_int64_t ind, buffsize;
} ov_decode_t;


static size_t ovcb_read (void *ptr, size_t size, size_t nb, void *datasource)
{
	ov_decode_t *ov_decode = (ov_decode_t*)datasource;
	size_t remain, len;

	remain = ov_decode->buffsize - ov_decode->ind;
	len = size * nb;
	if (remain < len)
		len = remain - remain % size;

	memcpy (ptr, ov_decode->buffer + ov_decode->ind, len);
	ov_decode->ind += len;

	return len / size;
}

static int ovcb_seek (void *datasource, ogg_int64_t offset, int whence)
{
	ov_decode_t *ov_decode = (ov_decode_t*)datasource;

	switch (whence)
	{
		case SEEK_SET:
			break;
		case SEEK_CUR:
			offset += ov_decode->ind;
			break;
		case SEEK_END:
			offset += ov_decode->buffsize;
			break;
		default:
			return -1;
	}
	if (offset < 0 || offset > ov_decode->buffsize)
		return -1;

	ov_decode->ind = offset;
	return 0;
}

static int ovcb_close (void *ov_decode)
{
	return 0;
}

static long ovcb_tell (void *ov_decode)
{
	return ((ov_decode_t*)ov_decode)->ind;
}


/*
=================================================================

  DLL load & unload

=================================================================
*/

/*
====================
OGG_OpenLibrary

Try to load the VorbisFile DLL
====================
*/
qboolean OGG_OpenLibrary (void)
{
	const char* dllnames_vo [] =
	{
#if defined(WIN64)
		"libvorbis64.dll",
#elif defined(WIN32)
		"libvorbis.dll",
		"vorbis.dll",
#elif defined(MACOSX)
		"libvorbis.dylib",
#else
		"libvorbis.so.0",
		"libvorbis.so",
#endif
		NULL
	};
	const char* dllnames_vf [] =
	{
#if defined(WIN64)
		"libvorbisfile64.dll",
#elif defined(WIN32)
		"libvorbisfile.dll",
		"vorbisfile.dll",
#elif defined(MACOSX)
		"libvorbisfile.dylib",
#else
		"libvorbisfile.so.3",
		"libvorbisfile.so",
#endif
		NULL
	};

	// Already loaded?
	if (vf_dll)
		return true;

// COMMANDLINEOPTION: Sound: -novorbis disables ogg vorbis sound support
	if (COM_CheckParm("-novorbis"))
		return false;

	// Load the DLLs
	// We need to load both by hand because some OSes seem to not load
	// the vorbis DLL automatically when loading the VorbisFile DLL
	if (! Sys_LoadLibrary (dllnames_vo, &vo_dll, NULL) ||
		! Sys_LoadLibrary (dllnames_vf, &vf_dll, oggvorbisfuncs))
	{
		Sys_UnloadLibrary (&vo_dll);
		Con_Printf ("Ogg Vorbis support disabled\n");
		return false;
	}

	Con_Printf ("Ogg Vorbis support enabled\n");
	return true;
}


/*
====================
OGG_CloseLibrary

Unload the VorbisFile DLL
====================
*/
void OGG_CloseLibrary (void)
{
	Sys_UnloadLibrary (&vf_dll);
	Sys_UnloadLibrary (&vo_dll);
}


/*
=================================================================

	Ogg Vorbis decoding

=================================================================
*/

#define STREAM_BUFFER_DURATION 1.5f	// 1.5 sec
#define STREAM_BUFFER_SIZE(format_ptr) ((int)(ceil (STREAM_BUFFER_DURATION * ((format_ptr)->speed * (format_ptr)->width * (format_ptr)->channels))))

// We work with 1 sec sequences, so this buffer must be able to contain
// 1 sec of sound of the highest quality (48 KHz, 16 bit samples, stereo)
static unsigned char resampling_buffer [48000 * 2 * 2];


// Per-sfx data structure
typedef struct
{
	unsigned char	*file;
	size_t			filesize;
	snd_format_t	format;
} ogg_stream_persfx_t;

// Per-channel data structure
typedef struct
{
	OggVorbis_File	vf;
	ov_decode_t		ov_decode;
	unsigned int	sb_offset;
	int				bs;
	snd_buffer_t	sb;		// must be at the end due to its dynamically allocated size
} ogg_stream_perchannel_t;


static const ov_callbacks callbacks = {ovcb_read, ovcb_seek, ovcb_close, ovcb_tell};

/*
====================
OGG_FetchSound
====================
*/
static const snd_buffer_t* OGG_FetchSound (channel_t* ch, unsigned int* start, unsigned int nbsampleframes)
{
	ogg_stream_perchannel_t* per_ch;
	sfx_t* sfx;
	ogg_stream_persfx_t* per_sfx;
	snd_buffer_t* sb;
	int newlength, done, ret, bigendian;
	unsigned int real_start;
	unsigned int factor;

	per_ch = (ogg_stream_perchannel_t *)ch->fetcher_data;
	sfx = ch->sfx;
	per_sfx = (ogg_stream_persfx_t *)sfx->fetcher_data;

	// If there's no fetcher structure attached to the channel yet
	if (per_ch == NULL)
	{
		size_t buff_len, memsize;
		snd_format_t sb_format;

		sb_format.speed = snd_renderbuffer->format.speed;
		sb_format.width = per_sfx->format.width;
		sb_format.channels = per_sfx->format.channels;

		buff_len = STREAM_BUFFER_SIZE(&sb_format);
		memsize = sizeof (*per_ch) - sizeof (per_ch->sb.samples) + buff_len;
		per_ch = (ogg_stream_perchannel_t *)Mem_Alloc (snd_mempool, memsize);
		sfx->memsize += memsize;

		// Open it with the VorbisFile API
		per_ch->ov_decode.buffer = per_sfx->file;
		per_ch->ov_decode.ind = 0;
		per_ch->ov_decode.buffsize = per_sfx->filesize;
		if (qov_open_callbacks (&per_ch->ov_decode, &per_ch->vf, NULL, 0, callbacks) < 0)
		{
			Con_Printf("error while reading Ogg Vorbis stream \"%s\"\n", sfx->name);
			Mem_Free (per_ch);
			return NULL;
		}
		per_ch->bs = 0;

		per_ch->sb_offset = 0;
		per_ch->sb.format = sb_format;
		per_ch->sb.nbframes = 0;
		per_ch->sb.maxframes = buff_len / (per_ch->sb.format.channels * per_ch->sb.format.width);

		ch->fetcher_data = per_ch;
	}
	
	real_start = *start;

	sb = &per_ch->sb;
	factor = per_sfx->format.width * per_sfx->format.channels;

	// If the stream buffer can't contain that much samples anyway
	if (nbsampleframes > sb->maxframes)
	{
		Con_Printf ("OGG_FetchSound: stream buffer too small (%u sample frames required)\n", nbsampleframes);
		return NULL;
	}

	// If the data we need has already been decompressed in the sfxbuffer, just return it
	if (per_ch->sb_offset <= real_start && per_ch->sb_offset + sb->nbframes >= real_start + nbsampleframes)
	{
		*start = per_ch->sb_offset;
		return sb;
	}

	newlength = (int)(per_ch->sb_offset + sb->nbframes) - real_start;

	// If we need to skip some data before decompressing the rest, or if the stream has looped
	if (newlength < 0 || per_ch->sb_offset > real_start)
	{
		unsigned int time_start;
		ogg_int64_t ogg_start;
		int err;
		
		if (real_start > sfx->total_length)
		{
			Con_Printf ("OGG_FetchSound: asked for a start position after the end of the sfx! (%u > %u)\n",
						real_start, sfx->total_length);
			return NULL;
		}

		// We work with 200ms (1/5 sec) steps to avoid rounding errors
		time_start = real_start * 5 / snd_renderbuffer->format.speed;
		ogg_start = time_start * (per_sfx->format.speed / 5);
		err = qov_pcm_seek (&per_ch->vf, ogg_start);
		if (err != 0)
		{
			Con_Printf ("OGG_FetchSound: qov_pcm_seek(..., %d) returned %d\n",
						real_start, err);
			return NULL;
		}
		sb->nbframes = 0;

		real_start = (float)ogg_start / per_sfx->format.speed * snd_renderbuffer->format.speed;
		if (*start - real_start + nbsampleframes > sb->maxframes)
		{
			Con_Printf ("OGG_FetchSound: stream buffer too small after seek (%u sample frames required)\n",
						*start - real_start + nbsampleframes);
			per_ch->sb_offset = real_start;
			return NULL;
		}
	}
	// Else, move forward the samples we need to keep in the sound buffer
	else
	{
		memmove (sb->samples, sb->samples + (real_start - per_ch->sb_offset) * factor, newlength * factor);
		sb->nbframes = newlength;
	}

	per_ch->sb_offset = real_start;

	// We add exactly 1 sec of sound to the buffer:
	// 1- to ensure we won't lose any sample during the resampling process
	// 2- to force one call to OGG_FetchSound per second to regulate the workload
	if (sb->format.speed + sb->nbframes > sb->maxframes)
	{
		Con_Printf ("OGG_FetchSound: stream buffer overflow (%u sample frames / %u)\n",
					sb->format.speed + sb->nbframes, sb->maxframes);
		return NULL;
	}
	newlength = per_sfx->format.speed * factor;  // -> 1 sec of sound before resampling

	// Decompress in the resampling_buffer
#if BYTE_ORDER == BIG_ENDIAN
	bigendian = 1;
#else
	bigendian = 0;
#endif
	done = 0;
	while ((ret = qov_read (&per_ch->vf, (char *)&resampling_buffer[done], (int)(newlength - done), bigendian, 2, 1, &per_ch->bs)) > 0)
		done += ret;

	Snd_AppendToSndBuffer (sb, resampling_buffer, (size_t)done / (size_t)factor, &per_sfx->format);

	*start = per_ch->sb_offset;
	return sb;
}


/*
====================
OGG_FetchEnd
====================
*/
static void OGG_FetchEnd (channel_t* ch)
{
	ogg_stream_perchannel_t* per_ch;

	per_ch = (ogg_stream_perchannel_t *)ch->fetcher_data;
	if (per_ch != NULL)
	{
		size_t buff_len;

		// Free the ogg vorbis decoder
		qov_clear (&per_ch->vf);

		buff_len = per_ch->sb.maxframes * per_ch->sb.format.channels * per_ch->sb.format.width;
		ch->sfx->memsize -= sizeof (*per_ch) - sizeof (per_ch->sb.samples) + buff_len;

		Mem_Free (per_ch);
		ch->fetcher_data = NULL;
	}
}


/*
====================
OGG_FreeSfx
====================
*/
static void OGG_FreeSfx (sfx_t* sfx)
{
	ogg_stream_persfx_t* per_sfx = (ogg_stream_persfx_t *)sfx->fetcher_data;

	// Free the Ogg Vorbis file
	Mem_Free(per_sfx->file);
	sfx->memsize -= per_sfx->filesize;

	// Free the stream structure
	Mem_Free(per_sfx);
	sfx->memsize -= sizeof (*per_sfx);

	sfx->fetcher_data = NULL;
	sfx->fetcher = NULL;
}


/*
====================
OGG_GetFormat
====================
*/
static const snd_format_t* OGG_GetFormat (sfx_t* sfx)
{
	ogg_stream_persfx_t* per_sfx = (ogg_stream_persfx_t *)sfx->fetcher_data;
	return &per_sfx->format;
}

static const snd_fetcher_t ogg_fetcher = { OGG_FetchSound, OGG_FetchEnd, OGG_FreeSfx, OGG_GetFormat };


/*
====================
OGG_LoadVorbisFile

Load an Ogg Vorbis file into memory
====================
*/
qboolean OGG_LoadVorbisFile (const char *filename, sfx_t *sfx)
{
	unsigned char *data;
	fs_offset_t filesize;
	ov_decode_t ov_decode;
	OggVorbis_File vf;
	vorbis_info *vi;
	ogg_int64_t len, buff_len;

	if (!vf_dll)
		return false;

	// Already loaded?
	if (sfx->fetcher != NULL)
		return true;

	// Load the file
	data = FS_LoadFile (filename, snd_mempool, false, &filesize);
	if (data == NULL)
		return false;

	Con_DPrintf ("Loading Ogg Vorbis file \"%s\"\n", filename);

	// Open it with the VorbisFile API
	ov_decode.buffer = data;
	ov_decode.ind = 0;
	ov_decode.buffsize = filesize;
	if (qov_open_callbacks (&ov_decode, &vf, NULL, 0, callbacks) < 0)
	{
		Con_Printf ("error while opening Ogg Vorbis file \"%s\"\n", filename);
		Mem_Free(data);
		return false;
	}

	// Get the stream information
	vi = qov_info (&vf, -1);
	if (vi->channels < 1 || vi->channels > 2)
	{
		Con_Printf("%s has an unsupported number of channels (%i)\n",
					sfx->name, vi->channels);
		qov_clear (&vf);
		Mem_Free(data);
		return false;
	}

	len = qov_pcm_total (&vf, -1) * vi->channels * 2;  // 16 bits => "* 2"

	// Decide if we go for a stream or a simple PCM cache
	buff_len = (int)ceil (STREAM_BUFFER_DURATION * (snd_renderbuffer->format.speed * 2 * vi->channels));
	if (snd_streaming.integer && len > (ogg_int64_t)filesize + 3 * buff_len)
	{
		ogg_stream_persfx_t* per_sfx;

		Con_DPrintf ("\"%s\" will be streamed\n", filename);
		per_sfx = (ogg_stream_persfx_t *)Mem_Alloc (snd_mempool, sizeof (*per_sfx));
		sfx->memsize += sizeof (*per_sfx);
		per_sfx->file = data;
		per_sfx->filesize = filesize;
		sfx->memsize += filesize;

		per_sfx->format.speed = vi->rate;
		per_sfx->format.width = 2;  // We always work with 16 bits samples
		per_sfx->format.channels = vi->channels;

		sfx->fetcher_data = per_sfx;
		sfx->fetcher = &ogg_fetcher;
		sfx->loopstart = -1;
		sfx->flags |= SFXFLAG_STREAMED;
		sfx->total_length = (int)((size_t)len / (per_sfx->format.channels * 2) * ((double)snd_renderbuffer->format.speed / per_sfx->format.speed));
	}
	else
	{
		char *buff;
		ogg_int64_t done;
		int bs, bigendian;
		long ret;
		snd_buffer_t *sb;
		snd_format_t ogg_format;

		Con_DPrintf ("\"%s\" will be cached\n", filename);

		// Decode it
		buff = (char *)Mem_Alloc (snd_mempool, (int)len);
		done = 0;
		bs = 0;
#if BYTE_ORDER == BIG_ENDIAN
		bigendian = 1;
#else
		bigendian = 0;
#endif
		while ((ret = qov_read (&vf, &buff[done], (int)(len - done), bigendian, 2, 1, &bs)) > 0)
			done += ret;

		// Build the sound buffer
		ogg_format.speed = vi->rate;
		ogg_format.channels = vi->channels;
		ogg_format.width = 2;  // We always work with 16 bits samples
		sb = Snd_CreateSndBuffer ((unsigned char *)buff, (size_t)done / (vi->channels * 2), &ogg_format, snd_renderbuffer->format.speed);
		if (sb == NULL)
		{
			qov_clear (&vf);
			Mem_Free (data);
			Mem_Free (buff);
			return false;
		}

		sfx->fetcher = &wav_fetcher;
		sfx->fetcher_data = sb;

		sfx->total_length = sb->nbframes;
		sfx->memsize += sb->maxframes * sb->format.channels * sb->format.width + sizeof (*sb) - sizeof (sb->samples);

		sfx->loopstart = -1;
		sfx->flags &= ~SFXFLAG_STREAMED;

		qov_clear (&vf);
		Mem_Free (data);
		Mem_Free (buff);
	}

	return true;
}
