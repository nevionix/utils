#####################################################################
# printmon.sh
# Requires: inotifywait (inotify-tools)
#
# A script utilizing inotifywait to monitor printer directories
# for txt file output from a program. Based on the directory, the
# script will print to the designated printer for that directory
# or perform other tasks.
#
# Keith Williams
# Updated: 28/10/2025
#
#####################################################################

DIR="/x/utils"

cd $DIR

inotifywait -qmr /x/printers -e create |
        while read path action file 
        do
          PRINTER=`echo $path | cut -d"/" -f4`
          FNAME=`date +%Y%m%d-%H%M`
          
          # Get the user from the filename of the output file (EP System)
          WHO=`ls -la $path$file | awk '{ print $3 }'`

          # If printing from SCO Openserver to a raw printer on linux via LPD
          # a banner will print. The following removes the banner
          # sudo sed -i '1,4d' $path$file

          # Use case to match the printer to print to
	    case $PRINTER in

          "PDF") # Plain PDF Printer
                if [ "$WHO" == "root" ]; then
                  sudo lp -d PDF -o cpi=17 -o lpi=6 -s $path$file
                  sudo rm -f $path$file
                else
                  PDFNAME=`echo $file | cut -d"." -f1`
                  sudo lp -d PDF -o cpi=17 -o lpi=6 -s $path$file
                  sleep 2
                  sudo mv /root/PDF/$PDFNAME.pdf /home/$WHO/PDF/
                  sudo chown $WHO /home/$WHO/PDF/$PDFNAME.pdf
                  sudo rm -f $path$file
                fi
	      ;;

	      "PDFinv") # PDF Invoice with overlay
                # pdftk $WHO.pdf background EPINV_TEMP.pdf output EPTestDoc.pdf
	      ;;

          "Samsung-M267x-287x") # Keith's Samsung printer
                sudo lp -d Samsung-M267x-287x -o cpi=17 -o lpi=6 -s $path$file
                sudo rm -f $path$file
              ;;

	   "*") break
	      ;;

	    esac
        done

# A email function
#          if [ "$file" = "email" ]
#            then
#                BODY="Your PDF is attached"
#                ./swaks \
#                  -tls \
#                  --tls-protocol tlsv1_2 \
#                  --server mail.x.co.za:587 \
#                  --helo epapps.x.co.za \
#                  --auth LOGIN \
#                  --au $EMAIL \
#                  --ap $PASS \
#                  --to $WHO@domain.co.za \
#                  --from $FROM \
#                  --header "Subject: PDF" \
#                  --body "$BODY" \
#                  --attach @/home/$WHO/PDF/$PDFNAME.pdf >/dev/null 2>&1
#          fi
