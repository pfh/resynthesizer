
; Smart Remove

; Smart selection eraser.
; Requires resynthesizer plug-in.
; Paul Harrison (pfh@logarithmic.net)

(define (script-fu-smart-remove img layer corpus-border)
  (cond
    ((= 0 (car (gimp-selection-bounds img))) 
      (gimp-message "To use this script-fu, first select the region you wish to remove.")
    )
    (#t (let*
      (
        (width  (car (gimp-drawable-width layer)))
        (height (car (gimp-drawable-height layer)))

        (dupe (car (gimp-image-duplicate img)))

        (channel (car (gimp-selection-save dupe)))
      )

      (gimp-selection-grow dupe corpus-border)
      (gimp-selection-invert dupe)
      (let*
        (
	  (old-background (car (gimp-context-get-background)))
          (channel2 (car (gimp-selection-save dupe)))
        )

        (gimp-selection-load channel)
	(gimp-context-set-background '(255 255 255))
        (gimp-edit-clear channel2)
	(gimp-context-set-background old-background)
        (gimp-selection-load channel2)
      )

      (gimp-selection-invert dupe)
      (let*
        (
          (bounds (gimp-selection-bounds dupe))
	  (x1 (nth 1 bounds))
	  (y1 (nth 2 bounds))
	  (x2 (nth 3 bounds))
	  (y2 (nth 4 bounds))
        )

        (gimp-image-crop dupe (- x2 x1) (- y2 y1) x1 y1)
      )
      (gimp-selection-invert dupe)

      (plug-in-resynthesizer 
        1 
        img
        layer
        0
        0
        1
        layer ;hmm, seems to work, was (car (gimp-image-get-active-layer dupe))
        -1
        -1
        0.0 0.117 16 500)

      (gimp-image-delete dupe)
    
      (gimp-displays-flush)
) ) ))

(script-fu-register "script-fu-smart-remove"
                    "<Image>/Filters/Enhance/Smart remove selection..."
		    "Remove an object from an image by extending surrounding texture to cover it.

Requires resynthesizer plug-in."
		    "Paul Harrison (pfh@logarithmic.net)"
		    "Paul Harrison"
		    "13/9/2000"
		    "RGB* GRAY*"
		    SF-IMAGE "Input Image" 0
		    SF-DRAWABLE "Input Layer" 0
		    SF-ADJUSTMENT "Radius to take texture from" '(100 7 1000 1.0 1.0 0 1)
)

