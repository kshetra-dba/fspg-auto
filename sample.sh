rm -Rf /usr/local/HammerDB-3.3
mkdir -p /usr/local/HammerDB-3.3
echo "---------------- down load the workload files -----------------------------"
curl 'https://microsoftapc-my.sharepoint.com/personal/ktutika_microsoft_com/_layouts/15/download.aspx?SourceUrl=%2Fpersonal%2Fktutika%5Fmicrosoft%5Fcom%2FDocuments%2Fdbtune%2FLatest%2Fhammerauto%2Ezip' \
  -H 'authority: microsoftapc-my.sharepoint.com' \
  -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
  -H 'accept-language: en-US,en;q=0.9' \
  -H 'cookie: MicrosoftApplicationsTelemetryDeviceId=7d838d5f-6f35-4409-99ca-11488f691b17; MicrosoftApplicationsTelemetryFirstLaunchTime=; rtFa=FCB3rFeFwdJYCGDEMgFf1IkCi6E7h8XtHwdwGsILUf0mRUM2M0IwOUItOTc0OC00N0JBLTkwMTgtQkVFQURENDA1MjA0IzEzMzQyNzgxMDE4NjM0MTc4MyNGOEQyRTdBMC1DMDE5LTIwMDAtQTY4QS03QTJBRkYzQzc4MUYjS1RVVElLQSU0ME1JQ1JPU09GVC5DT00jMTk1OTI2I1ZUR0NCRVRHUERJU1FLRUhWRVNQRi0xQU1KSQA15bITcPEK5K9eteNcZhpFOHqJ9gxZaodgiq8rYK0gq8WSJhkmJq5/CoFWMqRXXHhNHggXtWUuxUsA2Ckilg7jWdsEU3mQrc09UInN/Nw8hmwKOMykB5xI8XlFh60nI6jAdqqgFN5rBtqc67b7yoMpex3lR8xZZoRkv8Q6e4bzmBYzl86SPeNIJa8X2jxDJ12aU0GKANWKrjGTnHwnCx3TyPZ02tRwhitRXBwtQRmiYVSGghKjA8H+FywbfO/3IX9MYGgY7vw/g6E0q6XMdODFi496cX3tRMZlTDmsGHe57zH2fT++s23raOwInBG9nTET0Z+Du+xSiS6PJaWipAu4AAAA; SIMI=eyJzdCI6MH0=; MicrosoftApplicationsTelemetryDeviceId=7d838d5f-6f35-4409-99ca-11488f691b17; FedAuth=77u/PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz48U1A+VjEzLDBoLmZ8bWVtYmVyc2hpcHwxMDAzMjAwMWZjMWNkODIxQGxpdmUuY29tLDAjLmZ8bWVtYmVyc2hpcHxrdHV0aWthQG1pY3Jvc29mdC5jb20sMTMzNDI3ODAyNTEwMDAwMDAwLDEzMjk4NDY2MjUzMDAwMDAwMCwxMzM0MzIxODE4MTE2OTM0MjEsMjQwNDpmODAxOjgwMjg6Mzo5ZDMxOjE2NWQ6ZmFiZjoxY2RhLDczOSxlYzYzYjA5Yi05NzQ4LTQ3YmEtOTAxOC1iZWVhZGQ0MDUyMDQsLDQzODFkODY3LWU1OTQtNGZhMS1hMTY3LTliMWVhYzQwMzI5ZCxmOGQyZTdhMC1jMDE5LTIwMDAtYTY4YS03YTJhZmYzYzc4MWYsZTRkN2U3YTAtMTA4Mi0yMDAwLWFhOGUtNTg0NjdmNmQzYWMzLCwwLDEzMzQyODEyNjI2NjIxMDI0MSwxMzM0MzA2ODIyNjYyMTAyNDEsLCxleUpqWVhCdmJHbGtjMTlzWVhSbFltbHVaQ0k2SWx0Y0lqVTVOVFptWmpWaExUWm1aR0l0TkRjM1pTMDVaRFJrTFRsbU4yUXlOakpsTmprMFlWd2lYU0lzSW5odGMxOWpZeUk2SWx0Y0lrTlFNVndpWFNJc0luaHRjMTl6YzIwaU9pSXhJaXdpZUcxelgyTmhaV05vWldOcmN5STZJakVpTENKd2NtVm1aWEp5WldSZmRYTmxjbTVoYldVaU9pSnJkSFYwYVd0aFFHMXBZM0p2YzI5bWRDNWpiMjBpTENKMWRHa2lPaUpaVTBabmJtdG1lVW93UTJacVEzcHpUV0ZGVVVGQkluMD0sMjY1MDQ2Nzc0Mzk5OTk5OTk5OSwxMzM0Mjc4MTAxODAwMDAwMDAsMmIyOWJiMTQtNmI2NC00NmU5LWJmNjYtZmU1OTA4YjcxZGRjLCwsLCwsMCwsMTk1OTI2LEdBZHhXWDNxZy1wbFA0ZTlYQlAxeTE2aWZqVSxrT3JzZUU1cnpJRFR5NUVWTE82Q0tFdThrUWRvNVFXSXhEWWtKWVJVbWx4V2l3cExXOFR0Z25FVmlNZjdnL2JCSDlTbzJiSFlSdC8zMWdZMG1MUFlDb3czUHBWNFpvc1ZhUkw5a1h5UmRQTDRDZVcxeEQweWlYTEhKdW5DVVVJS2hjckJiVDRLQXVDYndoZWU0eFFOOC9xbmZyRi9MR0FJYkU2Y2VlZllpSmhpOThSUVZBUUdKQVl5ZzZpWFhxcFRxK2gzcWhxUkZQYnhvb2l0RjR5NlhlYUpxOUNBZlFob3ZSUUNmQ1pUQzFTOVB3TFNnU2lwa0lBZHo4VXpyeklyZWYxTkw0UGNoeU40UGtLTEJvN2FGNVJkWWNHTXp6enlLbGQ5aUNQMTcvUm9LdUNxSkZiVkdTbjRvRzdzUkNsMERRWXhXaG43YytYZHRlc1JIM0k5UFE9PTwvU1A+' \
  -H 'if-none-match: "{ED2945F6-0B32-42F6-A934-8F79612BEB6A},5"' \
  -H 'referer: https://microsoftapc-my.sharepoint.com/personal/ktutika_microsoft_com/_layouts/15/onedrive.aspx?id=%2Fpersonal%2Fktutika%5Fmicrosoft%5Fcom%2FDocuments%2Fdbtune%2FLatest%2Fhammerauto%2Ezip&parent=%2Fpersonal%2Fktutika%5Fmicrosoft%5Fcom%2FDocuments%2Fdbtune%2FLatest&ga=1' \
  -H 'sec-ch-ua: "Chromium";v="118", "Google Chrome";v="118", "Not=A?Brand";v="99"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Windows"' \
  -H 'sec-fetch-dest: iframe' \
  -H 'sec-fetch-mode: navigate' \
  -H 'sec-fetch-site: same-origin' \
  -H 'sec-fetch-user: ?1' \
  -H 'service-worker-navigation-preload: true' \
  -H 'upgrade-insecure-requests: 1' \
  -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36' \
  --compressed --output /usr/local/HammerDB-3.3/workloadfiles.zip

cd /usr/local/HammerDB-3.3 && unzip workloadfiles.zip

PGHOST=$(grep -A1 'workload:' /root/hammerauto/database.yml | tail -n1); PGHOST=${PGHOST//*pghost: /}
PGDATABASE=$(grep -A2 'workload:' /root/hammerauto/database.yml | tail -n1); PGDATABASE=${PGDATABASE//*pgdatabase: /}
LOGIN_USER=$(grep -A3 'workload:' /root/hammerauto/database.yml | tail -n1); LOGIN_USER=${LOGIN_USER//*login_user: /}
PGPASSWORD=$(grep -A4 'workload:' /root/hammerauto/database.yml | tail -n1); PGPASSWORD=${PGPASSWORD//*pgpassword: /}
WORKLOAD_DURATION=$(grep -A5 'workload:' /root/hammerauto/database.yml | tail -n1); WORKLOAD_DURATION=${WORKLOAD_DURATION//*workload_duration: /}
WORKLOAD_TYPE=$(grep -A6 'workload:' /root/hammerauto/database.yml | tail -n1); WORKLOAD_TYPE=${WORKLOAD_TYPE//*workload_type: /}
VCORE=$(grep -A7 'workload:' /root/hammerauto/database.yml | tail -n1); VCORE=${VCORE//*vcore: /}

chmod u+x /usr/local/HammerDB-3.3/hammerauto/*.sh

sed -i -e "s/PGHOST/$PGHOST/g" -e "s/LOGIN_USER/$LOGIN_USER/g" -e "s/PGPASSWORD/$PGPASSWORD/g" -e "s/WORKLOAD_DURATION/$WORKLOAD_DURATION/g" -e "s/PGDATABASE/$PGDATABASE/g" /usr/local/HammerDB-3.3/hammerauto/*.sh
export PGPASSWORD=$PGPASSWORD

if [[ $WORKLOAD_TYPE == "read" && $VCORE == 8 ]] ; then
        echo "Initiating load on read heavy 8 v core server"
elif [[ $WORKLOAD_TYPE == "read" && $VCORE == 16 ]]; then
        echo "Initiating load on read heavy 16 v core server"
elif [[ $WORKLOAD_TYPE == "write" && $VCORE == 8 ]]; then
        echo "Initiating load on write heavy 8 v core server"
elif [[ $WORKLOAD_TYPE == "write" && $VCORE == 16 ]]; then
        echo "Initiating load on write heavy 16 v core server"
elif [[ $WORKLOAD_TYPE == "mixed" && $VCORE == 8 ]]; then
        echo "Initiating load on mixed heavy 8 v core server"
else
        echo "Initiating load on mixed heavy 16 v core server"
fi
