#   ----------------------------------------------------------------------------
#	COPYRIGHT (C) 2018-2019 David Knapp
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#   ----------------------------------------------------------------------------


### VARIABLES ###

set(ENGINE_PLATFLAGS "-Wall -Wno-pointer-sign -Wno-unknown-pragmas -Wno-format-zero-length -Wno-strict-aliasing -Dstrnicmp=strncasecmp -Dstricmp=strcasecmp")

if(ENGINE_VERSION)
	set(ENGINE_FLAGS "${ENGINE_FLAGS} -DSVNREVISION='${ENGINE_VERSION}'")
endif()

if(CMAKE_BUILD_TYPE)
	set(ENGINE_FLAGS "${ENGINE_FLAGS} -DBUILDTYPE='${CMAKE_BUILD_TYPE}'")
endif()

if(ENGINE_NO_BUILD_TIMESTAMPS)
	set(ENGINE_FLAGS "${ENGINE_FLAGS} -DNO_BUILD_TIMESTAMPS")
endif()

if(MINGW)
	set(ENGINE_PLATLIBS "-lm -lwinmm -limm32 -lversion -lwsock32 -lws2_32")
elseif(UNIX AND NOT APPLE)
	set(ENGINE_PLATLIBS "-lm -ldl -lz -lrt")
	if(SUN_OS)
		set(ENGINE_PLATLIBS "${ENGINE_PLATLIBS} -lsocket -lnsl")
	endif()
endif()

if(APPLE)
	set(ENGINE_PLATLIBS "-lm -ldl -lz -framework IOKit -framework CoreFoundation")
endif()

### INCLUDE ###

set(OBJ_SND_COMMON
	${ENGINE_DIR}/snd_main.c
	${ENGINE_DIR}/snd_mem.c
	${ENGINE_DIR}/snd_mix.c
	${ENGINE_DIR}/snd_ogg.c
	${ENGINE_DIR}/snd_wav.c
)

set(OBJ_VIDEO_CAPTURE
	${ENGINE_DIR}/cap_avi.c
	${ENGINE_DIR}/cap_ogg.c
)

set(OBJ_COMMON
	${ENGINE_DIR}/bih.c
	${ENGINE_DIR}/builddate.c
	${ENGINE_DIR}/crypto.c
	${ENGINE_DIR}/cl_collision.c
	${ENGINE_DIR}/cl_demo.c
	${ENGINE_DIR}/cl_dyntexture.c
	${ENGINE_DIR}/cl_input.c
	${ENGINE_DIR}/cl_main.c
	${ENGINE_DIR}/cl_parse.c
	${ENGINE_DIR}/cl_particles.c
	${ENGINE_DIR}/cl_screen.c
	${ENGINE_DIR}/cl_video.c
	${ENGINE_DIR}/clvm_cmds.c
	${ENGINE_DIR}/cmd.c
	${ENGINE_DIR}/collision.c
	${ENGINE_DIR}/common.c
	${ENGINE_DIR}/console.c
	${ENGINE_DIR}/csprogs.c
	${ENGINE_DIR}/curves.c
	${ENGINE_DIR}/cvar.c
	${ENGINE_DIR}/dpsoftrast.c
	${ENGINE_DIR}/dpvsimpledecode.c
	${ENGINE_DIR}/filematch.c
	${ENGINE_DIR}/fractalnoise.c
	${ENGINE_DIR}/fs.c
	${ENGINE_DIR}/ft2.c
	${ENGINE_DIR}/utf8lib.c
	${ENGINE_DIR}/gl_backend.c
	${ENGINE_DIR}/gl_draw.c
	${ENGINE_DIR}/gl_rmain.c
	${ENGINE_DIR}/gl_rsurf.c
	${ENGINE_DIR}/gl_textures.c
	${ENGINE_DIR}/hmac.c
	${ENGINE_DIR}/host.c
	${ENGINE_DIR}/host_cmd.c
	${ENGINE_DIR}/image.c
	${ENGINE_DIR}/image_png.c
	${ENGINE_DIR}/jpeg.c
	${ENGINE_DIR}/keys.c
	${ENGINE_DIR}/lhnet.c
	${ENGINE_DIR}/libcurl.c
	${ENGINE_DIR}/mathlib.c
	${ENGINE_DIR}/matrixlib.c
	${ENGINE_DIR}/mdfour.c
	${ENGINE_DIR}/meshqueue.c
	${ENGINE_DIR}/mod_skeletal_animatevertices_sse.c
	${ENGINE_DIR}/mod_skeletal_animatevertices_generic.c
	${ENGINE_DIR}/model_alias.c
	${ENGINE_DIR}/model_brush.c
	${ENGINE_DIR}/model_shared.c
	${ENGINE_DIR}/model_sprite.c
	${ENGINE_DIR}/netconn.c
	${ENGINE_DIR}/palette.c
	${ENGINE_DIR}/polygon.c
	${ENGINE_DIR}/portals.c
	${ENGINE_DIR}/protocol.c
	${ENGINE_DIR}/prvm_cmds.c
	${ENGINE_DIR}/prvm_edict.c
	${ENGINE_DIR}/prvm_exec.c
	${ENGINE_DIR}/r_explosion.c
	${ENGINE_DIR}/r_lightning.c
	${ENGINE_DIR}/r_modules.c
	${ENGINE_DIR}/r_shadow.c
	${ENGINE_DIR}/r_sky.c
	${ENGINE_DIR}/r_sprites.c
	${ENGINE_DIR}/sbar.c
	${ENGINE_DIR}/sv_demo.c
	${ENGINE_DIR}/sv_main.c
	${ENGINE_DIR}/sv_move.c
	${ENGINE_DIR}/sv_phys.c
	${ENGINE_DIR}/sv_user.c
	${ENGINE_DIR}/svbsp.c
	${ENGINE_DIR}/svvm_cmds.c
	${ENGINE_DIR}/sys_shared.c
	${ENGINE_DIR}/vid_shared.c
	${ENGINE_DIR}/view.c
	${ENGINE_DIR}/wad.c
	${ENGINE_DIR}/world.c
	${ENGINE_DIR}/zone.c
)

set(OBJ_MENU
	${ENGINE_DIR}/menu.c
	${ENGINE_DIR}/mvm_cmds.c
)

set(OBJ_SV
	${ENGINE_DIR}/sys_linux.c
	${ENGINE_DIR}/vid_null.c
	${ENGINE_DIR}/thread_null.c
	${ENGINE_DIR}/snd_null.c
)

set(OBJ_CL
	${ENGINE_DIR}/cd_sdl.c
	${ENGINE_DIR}/cd_shared.c
	${ENGINE_DIR}/snd_sdl.c
	${ENGINE_DIR}/sys_sdl.c
	${ENGINE_DIR}/vid_sdl.c
	${ENGINE_DIR}/thread_sdl.c
)

include(${MODULE_DIR}/target/client.cmake)
include(${MODULE_DIR}/target/server.cmake)
