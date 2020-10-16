#!/bin/bash
apt install -y jpegoptim optipng 
function _optimize_img {

    if [[ $1 = *.png ]];
    then
        echo "Optimize png"
        initialSize="`ls -sh $1 | cut -d' ' -f1 `"
        optipng  -o5 -fix -f4 -strip all  -quiet $1
        currentSize="`ls -sh $1 | cut -d' ' -f1`"
        echo "$1 optimized from $initialSize to $currentSize"
    fi
    
    if [[ $1 = *.jpg ]];
    then
        echo "Optimize jpg"
        initialSize="`ls -sh $1 | cut -d' ' -f1`"
        jpegoptim --strip-all -m90 -q $1
        currentSize="`ls -sh $1 | cut -d' ' -f1`"
        echo "$1 optimized from $initialSize to $currentSize"
    fi

}
export -f _optimize_img
find /srv/hub_uploads -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.jpeg \) -print0 | xargs -0 -n1 -P 4 -I {} bash -c '_optimize_img "{}"' 
apt remove -y jpegoptim optipng 
apt --purge autoremove -y
apt autoclean -y
