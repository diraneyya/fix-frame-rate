
# This command retrieves the frames per second of the input file (input.mp4). The frames 
# per second given out by 'ffprobe' command follow the following form: "A/B" where A and
# B are integers and there is a forward slash in-between the two.
%.fixed.mp4: FPS_SLASH=$(shell ffprobe -v 0 -of csv=p=0 -select_streams v:0 -show_entries \
	stream=avg_frame_rate $(@:.fixed.mp4=.mp4))
# By subtituting the slash with a space we are able to get the A/B integers using 'firstword'
# and 'lastword' (check https://gnu.org/software/make/manual/html_node/Text-Functions.html)
%.fixed.mp4: FPS_SPACE=$(subst /, ,$(FPS_SLASH))
%.fixed.mp4: FPS1=$(firstword $(FPS_SPACE))
%.fixed.mp4: FPS2=$(lastword $(FPS_SPACE))
# This command retrieves total number of frames in the input file (input.mp4) corresponding
# to (input.fixed.mp4).
%.fixed.mp4: FRAMES=$(shell ffprobe -v error -select_streams v:0 -count_packets -show_entries \
	stream=nb_read_packets -of csv=p=0 $(@:.fixed.mp4=.mp4))
%.fixed.mp4: DURATION=$(shell bc -l <<< "( $(FRAMES) * $(FPS1) ) / $(FPS2)")

# This is the recipe for generating fixed mp4 files. Note that the recipe expects an env
# variable "FPS" to hold the value of the target (desired) framerate.
%.fixed.mp4:
ifdef DEBUG 
	@echo "FPS_SLASH='$(FPS_SLASH)'"
	@echo "FPS1='$(FPS1)'"
	@echo "FPS2='$(FPS2)'"
else
ifndef FPS
	@echo "USAGE : make FPS=value file.fixed.mp4"
	@echo "This will fix the speed of 'file.mp4' and save it as 'file.fixed.mp4'."
else
	@echo "ORIGINAL DURATION: $(DURATION) second(s)"
	@echo "ORIGINAL FRAMERATE: $(FPS1) frames/$(FPS2) seconds"
	@echo "TARGET FRAMERATE: $(FPS) frames/second"
	ffmpeg -i $(@:.fixed.mp4=.mp4) \
	-filter:v "setpts=`bc -l <<< '$(FPS1) / ( $(FPS2) * $(FPS) )'`*PTS" \
	-r $(FPS) $@ 
endif
endif
