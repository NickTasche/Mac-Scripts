
###Functions###

function ip_lookup() {
   ipAddress=False

   ipAddress=$(ifconfig -a inet 2>/dev/null | grep inet | awk 'FNR ==2 {print $2}')

   ##Debug for IP##
   #ipAddress=10.132.12.7

   echo "DEBUGGING:\nClient IP Address: $ipAddress\n"

}


function network_lookup() {

network=False

network=$(curl --request GET \
 --silent \
 --url "https://10.121.10.0/wapi/v2.7/ipv4address?ip_address=$ipAddress" \
 --insecure \
 --header 'Accept: /' \
 --header 'Accept-Encoding: gzip, deflate' \
 --header 'Authorization: Basic YWRtaW46aW5mb2Jsb3g=' \
 --header 'Cache-Control: no-cache' \
 --header 'Connection: keep-alive' \
 --header 'Cookie: ibapauth="ip=153.32.228.3,client=API,group=admin-group,ctime=1568046690,timeout=10800,mtime=1568046690,su=1,auth=LOCAL,user=admin,JEZGEBnNWet1n8jMGDz7+H0biaOcUQpmB0Y"' \
 --header 'Host: 10.121.10.0' \
 --header 'Postman-Token: 74c367ff-123e-411b-965c-671bb0a1b867,9943cdd5-13e5-4116-a491-e42736905a6e' \
 --header 'User-Agent: PostmanRuntime/7.16.3' \
 --header 'cache-control: no-cache' \
 | grep network | awk -F'"' 'FNR ==1 {print $4}'
 )
 echo "Network Result: $network"

}


function city_lookup() {
city=False

##Network Spoof for City Debug##

#echo "Network Result: $network"

city=$(curl --request GET \
 --silent \
 --url "https://10.121.10.0/wapi/v2.7/network?network=${network}&_return_fields=extattrs" \
 --insecure \
 --header 'Accept: /' \
 --header 'Accept-Encoding: gzip, deflate' \
 --header 'Authorization: Basic YWRtaW46aW5mb2Jsb3g=' \
 --header 'Cache-Control: no-cache' \
 --header 'Connection: keep-alive' \
 --header 'Cookie: ibapauth="group=admin-group,ctime=1567621195,ip=153.32.228.3,su=1,client=API,auth=LOCAL,timeout=10800,mtime=1567628405,user=admin,/PW6hfVU7v8KvS/GHRbf+YPN6nkfpZr+4NI"' \
 --header 'Host: 10.121.10.0' \
 --header 'Postman-Token: bab86de7-9789-4b9e-a4e6-567285be1312,8f7f019f-ba7d-47f9-9dfb-9f4194c6447d' \
 --header 'User-Agent: PostmanRuntime/7.16.3' \
 --header 'cache-control: no-cache'\
#| grep -A 1 City | awk -F'"' 'FNR ==2 {print $4}'

 )
}

function server_route() {
  printServer=False
  serverRegion=False

  ##Debug for City##
  #city="Los Angeles"

  echo "City Result in Server Route: $city"

  case $city in

    "San Jose" | "Los Angeles" )
        printServer=printsj.corp.adobe.com
        echo "Print Server:$printServer"
	      serverRegion=AdobeSecurePrint ;;

    "Seattle" | "Austin" | "Portland" | "Denver" | "Hillsboro" )
	      printServer=printsea.corp.adobe.com
        echo "$printServer"
	      serverRegion=AdobeSecurePrint ;;

    "San Francisco" | "Emeryville" | "San Mateo")
	      printServer=printsf.corp.adobe.com
        echo "$printServer"
	      serverRegion=AdobeSecurePrint ;;

    "Lehi" )
     	  printServer=printut.corp.adobe.com
        echo "$printServer"
	      serverRegion=AdobeSecurePrint ;;

    "New York City" )
	      printServer=printeast.corp.adobe.com
        echo "$printServer"
	      serverRegion=AdobeSecurePrint ;;

    "Toronto" | "Ottawa" )
	      printServer=printeast.corp.adobe.com
        echo "$printServer"
	      serverRegion=AdobeSecurePrint ;;

    "Arden Hills" | "Chicago" | "McLean" | "Newton")
	      printServer=printeast.corp.adobe.com
        echo "$printServer"
	      serverRegion=AdobeSecurePrint ;;

    "Barcelona" | "Basel" | "Copenhagen" | "Dublin" | "Edinburgh" | "Paris" | "Stockholm" | "Warsaw" | "Zurich" )
	      printServer=10.129.104.83
        echo "$printServer"
        serverRegion=AdobeSecurePrintEU ;;

    "Amsterdam" | "Berlin" | "Brussels" | "Hamburg" | "Milan" | "Munich" )
        printServer=10.129.104.84
        echo "$printServer"
        serverRegion=AdobeSecurePrintEU ;;

    "Bucharest" )
	      printServer=10.131.237.6
        echo "$printServer"
	      serverRegion= AdobeSecurePrintEU ;;


  esac

}


function remove_printer() {
   lpstat -p | awk '{print $2}' | while read printer ; do

  #echo $printer

   if [[ "$printer" == *"SecurePrint"* ]] || [[ "$printer" == "Adobe_Secure_Print"* ]]
      then echo "Deleting Old Printer:" $printer
      lpadmin -x $printer
   fi

   done

}

function add_printer() {
   userName=False
   echo "What is your username?"
   read -p "> " userName

   remove_printer

   #[[ $? != 0 ]] && exit 1

   # Create variable for current directory
   mydir="$(dirname "$BASH_SOURCE")"

   #Echo $mydir

   /usr/sbin/lpadmin \
      -p "Adobe_SecurePrint" \
      -D "Adobe SecurePrint" \
      -E -v "lpd://${userName}@${printServer}/${serverRegion}" \
      -P "$mydir/CNADVC3525IIIX1.PPD" \
      -o printer-is-shared=false 2>/dev/null

   echo "lpd://${userName}@${printServer}/${serverRegion}"

   if [ $? != 0 ] ; then
      exit 2
   else

      echo "Printer has been added successfully."
      open "/System/Library/PreferencePanes/PrintAndScan.prefPane/"
      exit 0
   fi
}

function enable_cups() {
   cupsctl Webinterface=yes
}



###Main###


ip_lookup
network_lookup
city_lookup
server_route

echo "IP Address: $ipAddress"
echo "Network Address: $network"
echo "User City: $city"
echo "Server Region: $serverRegion"
echo "Printer Server: $printServer"


enable_cups
add_printer
