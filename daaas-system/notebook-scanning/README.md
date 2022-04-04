## Purpose
EPIC: https://github.com/StatCan/daaas/issues/461

Provide a way for user notebooks to be scanned and updated.

This is a WIP and we will be deploying what we have in parts (some may be combined).

Here's a general run through of what will happen.

Part 1:
Get a list of notebook servers which are affected by a non-ignored vulnerability as found by jfrog XRAY.
For the first deployment this can just be standard output written do the console.

Part 2:
Use the jupyter-web-app configmap as a truth / most up to date image, and create a list of 
images to update to (using the output from part 1)

Part 3: 
Send user emails about their notebook images that will be updated

Part 4: 
Update the images

Extra thoughts:
May make use of annotations to see when an image was scanned and then use that as 
information as to when to update it? Don't just send an email and then update the image right away.
