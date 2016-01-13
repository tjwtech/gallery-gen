#!/bin/bash

# Dependencies: ffmpeg image-magick md5sum

# Quality is the jpeg compression level for thumbnails. Valid value is between 0-100.
quality=65

# picpp (Thumbs Per Page) is how many thumbnails will appear per page on the picture gallery.
picpp=150

# Name of the gallery (default is the current directory)
name=${PWD##*/}

gallery () {
  # Index
  echo
  echo '<!DOCTYPE html>'"<html><head><title>Galleries and Index of $name</title></head><body style=\"background:#000;color:#00ff00;\"><h1>Galleries in $name " > index.htm
  if [ -d nsfw ]; then
    echo '<a href="nsfw/index.htm">[nsfw]<a>' >> index.htm
  fi
  echo "</h1><hr><a href=\"picgallery/index.htm\"><h2>Picture Gallery</h2></a><br><a href=\"vidgallery/index.htm\"><h2>Video Gallery</h2></a><br><a href=\"audgallery/index.htm\"><h2>Audio Gallery</h2></a><br><hr><h1>Index of $name</h1><hr><ul>" >> index.htm
  for i in *; do
    echo "<li><a href=\"$i\">$i</a><br></li>"
  done >> index.htm
  echo "</ul><hr><p>Index generated on: $(date)</p></body></html>" >> index.htm

  # Picture Gallery
  page=1
  thumbloop=1
  rm picgallery/index*
  mkdir -p picgallery/thumbs
  echo '<!DOCTYPE html><html><head><meta http-equiv="Refresh" content="0;url=index1.htm"></head></html>' > picgallery/index.htm
  echo '<!DOCTYPE html><html><head><meta http-equiv="Refresh" content="0;url=../"></head></html>' > picgallery/thumbs/index.htm
  for i in *.{jpg,jpeg,png,gif}; do
    if [ -f "$i" ]; then
      if [[ $thumbloop -eq 1 ]]; then
        echo '<!DOCTYPE html>'"<html><head><title>Picture Gallery of $name - Page $page</title></head><body style=\"background:#000;color:#00ff00;\"><h1>Picture Gallery of $name - Page $page</h1><hr>" > picgallery/index$page.htm
      fi
      thumbloop=$(($thumbloop + 1))
        if [ ! -f picgallery/thumbs/$(echo -n $i | md5sum | cut -f1 -d' ').jpg ]; then
          convert "$i" -quality $quality -thumbnail x150 -delete 1--1 "picgallery/thumbs/$(echo -n $i | md5sum | cut -f1 -d' ').jpg"
        fi
        echo "<a href=\"../$i\"><img src=\"thumbs/$(echo -n $i | md5sum | cut -f1 -d' ').jpg\" alt=\"$i\" title=\"$i\" height=\"150\"></a>" >> picgallery/index$page.htm
      if [ $thumbloop -gt $picpp ]; then
        thumbloop=1
        echo "<hr><p>Page: " >> picgallery/index$page.htm
        if [ $page -eq 1 ]; then
          echo "1 " >> picgallery/index$page.htm
        else
          for i in $(seq 1 $(($page - 1))); do
            echo "<a href=\"index$i.htm\">$i</a>" >> picgallery/index$page.htm
            echo "<a href=\"index$page.htm\">$page</a>" >> picgallery/index$i.htm
          done
          echo "$page " >> picgallery/index$page.htm
        fi
        page=$(($page + 1))
      fi
    fi
  done
    if [ $page -eq 1 ]; then
      echo "<hr><p>Index generated on: $(date)</p></body></html>" >> picgallery/index1.htm
    else
      for i in $(seq 1 $(($page - 1))); do
        echo "<hr><p>Index generated on: $(date)</p></body></html>" >> picgallery/index$i.htm
      done
    fi

  # Video Gallery
  mkdir -p vidgallery/thumbs vidgallery/vidpages
  echo '<!DOCTYPE html>'"<html><head><title>Video Gallery of $name</title></head><body style=\"background:#000;color:#00ff00;\"><h1>Video Gallery of $name</h1><hr>" > vidgallery/index.htm
  for i in *.{webm,mp4,flv,ogg}; do
    if [ -f "$i" ]; then
      if [ ! -f vidgallery/thumbs/$(echo -n $i | md5sum | cut -f1 -d' ').jpg ]; then
        ffmpeg -y -ss 0.5 -i "$i" -vframes 1 -vf 'yadif,scale=-2:480' "vidgallery/thumbs/$(echo -n $i | md5sum | cut -f1 -d' ').jpg"
      fi
      if [ ! -f vidgallery/vidpages/$(echo -n $i | md5sum | cut -f1 -d' ').htm ]; then
        echo "<!DOCTYPE html><html><head><title>Video: $i</title></head><body style=\"background:#000;color:#00ff00;\"><center><h1>$i</h1><br><br><video poster=\"../thumbs/$(echo -n $i | md5sum | cut -f1 -d' ').jpg\" height=\"480\" controls=\"controls\" preload=\"metadata\"><source src=\"../../$i\"></video></center></body></html>" > vidgallery/vidpages/$(echo -n $i | md5sum | cut -f1 -d' ').htm
      fi
      echo "<br><a href=\"vidpages/$(echo -n $i | md5sum | cut -f1 -d' ').htm\">$i</a><br><video poster=\"thumbs/$(echo -n $i | md5sum | cut -f1 -d' ').jpg\" height=\"480\" controls=\"controls\" preload=\"none\"><source src=\"../$i\"></video><br><br>"
    fi
  done >> vidgallery/index.htm
  echo "<hr><p>Index generated on: $(date)</p></body></html>" >> vidgallery/index.htm

  # Audio Gallery
  mkdir -p audgallery
  echo '<!DOCTYPE html>'"<html><head><title>Audio Gallery of $name</title></head><body style=\"background:#000;color:#00ff00;\"><h1>Audio Gallery of $name</h1><hr>" > audgallery/index.htm
  for i in *.{mp3,opus,aac,flac,oga,ogg}; do
    if [ -f "$i" ]; then
      echo "<br><a href=\"../$i\">$i</a><br><audio controls><source src=\"../$i\"></audio><br><br>"
    fi
  done >> audgallery/index.htm
  echo "<hr><p>Index generated on: $(date)</p></body></html>" >> audgallery/index.htm
}

gallery

if [ -d nsfw ]; then
  name="$name NSFW"
  cd nsfw
  gallery
fi
