/*
	Libavcodec integration for Darkplaces by Timofeyev Pavel

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
#ifndef CL_VIDEO_LIBAVW_H
#define CL_VIDEO_LIBAVW_H

// DP videostream
typedef struct libavwstream_s
{
	qfile_t     *file;
	double       info_framerate;
	unsigned int info_imagewidth;
	unsigned int info_imageheight;
	double       info_aspectratio;
	void        *stream;

	// channel the sound file is being played on
	sfx_t *sfx;
	int    sndchan;
	int    sndstarted;
}
libavwstream_t;

void *LibAvW_OpenVideo(clvideo_t *video, char *filename, const char **errorstring);
qboolean LibAvW_OpenLibrary(void);
void LibAvW_CloseLibrary(void);

#endif
