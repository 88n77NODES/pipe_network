#!/bin/bash

green='\033[0;32m'
nc='\033[0m'

wget https://raw.githubusercontent.com/88n77/Logo-88n77/main/logo.sh
chmod +x logo.sh
./logo.sh

sleep 2

setup_url="https://raw.githubusercontent.com/88n77NODES/pipe_network/main/setup.sh"
update_url="https://raw.githubusercontent.com/88n77NODES/pipe_network/main/updatee.sh"
delete_url="https://raw.githubusercontent.com/88n77NODES/pipe_network/main/deleted.sh"
points_url="https://raw.githubusercontent.com/88n77NODES/pipe_network/main/point.sh"  

menu_options=("Встановити" "Оновити" "Видалити" "Перевірити поїнти" "Вийти")
PS3='Оберіть дію: '

select choice in "${menu_options[@]}"
do
    case $choice in
        "Встановити")
            echo -e "${green}Встановлення...${nc}"
            bash <(curl -s $setup_url)
            ;;
        "Оновити")
            echo -e "${green}Оновлення...${nc}"
            bash <(curl -s $update_url)
            ;;
        "Видалити")
            echo -e "${green}Видалення...${nc}"
            bash <(curl -s $delete_url)
            ;;
        "Перевірити поїнти")
            echo -e "${green}Перевірка поїнтів...${nc}"
            bash <(curl -s $points_url)  
            ;;
        "Вийти")
            echo -e "${green}Вихід...${nc}"
            break
            ;;
        *)
            echo "Невірний вибір!"
            ;;
    esac
done
