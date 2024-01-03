# SPDX-License-Identifier: GPL-2.0
#
# Makefile for the ntfs3 filesystem support.
#

# to check robot warnings

KMODNAME=ntfs3
KMODVER=6.1.69

ccflags-y += -Wint-to-pointer-cast \
	$(call cc-option,-Wunused-but-set-variable,-Wunused-const-variable) \
	$(call cc-option,-Wold-style-declaration,-Wout-of-line-declaration)

obj-$(CONFIG_NTFS3_FS) += ntfs3.o

ntfs3-y :=	attrib.o \
		attrlist.o \
		bitfunc.o \
		bitmap.o \
		dir.o \
		fsntfs.o \
		frecord.o \
		file.o \
		fslog.o \
		inode.o \
		index.o \
		lznt.o \
		namei.o \
		record.o \
		run.o \
		super.o \
		upcase.o \
		xattr.o

ntfs3-$(CONFIG_NTFS3_LZX_XPRESS) += $(addprefix lib/,\
		decompress_common.o \
		lzx_decompress.o \
		xpress_decompress.o \
		)

ifeq ($(KVERSION),)
	KVERSION ?= $(shell uname -r)
endif

export CONFIG_NTFS3_FS := n
export CONFIG_NTFS3_64BIT_CLUSTER := n
export CONFIG_NTFS3_LZX_XPRESS := y
export CONFIG_NTFS3_FS_POSIX_ACL := y

all:
	make -C /lib/modules/$(KVERSION)/build M=$(PWD) modules

clean:
	make -C /lib/modules/$(KVERSION)/build M=$(PWD) clean
	
dkms:
	mkdir -p /usr/src/${KMODNAME}-${KMODVER}/
	cp -R . /usr/src/${KMODNAME}-${KMODVER}/
	dkms add -m ${KMODNAME} -v ${KMODVER}
	dkms build -m ${KMODNAME} -v ${KMODVER}
	dkms install -m ${KMODNAME} -v ${KMODVER}

dkms-uninstall:
	dkms remove -m ${KMODNAME} -v ${KMODVER}
