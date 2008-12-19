TARGET=wkpdf.dmg

all: release

release:
	xcodebuild -configuration Release -target $(TARGET)

debug:
	xcodebuild -configuration Debug -target $(TARGET)

dist: realclean
	make release
	@echo "upload DMG to website now"

clean:
	xcodebuild -alltargets clean

realclean:
	rm -rf build/*

.PHONY: release debug clean dist realclean
