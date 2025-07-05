#!/bin/bash

# Projekt IT Administrator -- easyTASKMASTER/správce úkolů

# Modularita pro barvy a export do markdown
source "./colors.sh"
source "./exportmd.sh"

# Vytvářím soubor s úkoly = proměnná definuje soubor
TASK_FILE="tasks.txt"

# Funkce přidat úkol
add_task() {
    read -p "$(echo -e "${BOLD}📝  Zadej popis nového úkolu:${NC} ")" task

    if [[ -z "$task" ]]; then
        echo -e "${YELLOW}⚠️  Úkol nemůže být prázdný!${NC}" # echo -e umožní barvy
        return
    fi

    echo "[ ] $task" >> "$TASK_FILE"
    echo -e "${GREEN}✅  Úkol přidán.${NC}" # dtto
}

# Funkce zobrazí vložené úkoly, barvy
show_tasks() {
    if [[ ! -s "$TASK_FILE" ]]; then
        echo -e "${YELLOW}⚠️  Žádné úkoly k zobrazení${NC}"
        return
    fi

    echo -e "${CYAN}${BOLD}📋  Seznam úkolů:${NC}"
    echo -e "${CYAN}-----------------${NC}"
    echo

    local i=1
    while IFS= read -r line; do
        echo -e "${BOLD}${i})${NC} $line"
        ((i++))
    done < "$TASK_FILE"
}

# Funkce zobrazí hlavní menu, barvy a bold
show_menu() {
  echo -e "${GREEN}${BOLD}----------------------------------------"
  echo -e "             easyTASKMASTER "
  echo -e "----------------------------------------${NC}"
  echo -e "${BOLD}1)${NC} Zobrazit všechny úkoly"
  echo -e "${BOLD}2)${NC} Přidat nový úkol"
  echo -e "${BOLD}3)${NC} Označit úkol jako dokončený"
  echo -e "${BOLD}4)${NC} Smazat úkol"
  echo -e "${BOLD}5)${NC} Export do Markdown"
  echo -e "${BOLD}6)${NC} Konec"
  echo
}

#  Funkce zobrazí úkol jako odškrtnutý, barvy
mark_task_done() {
    if [[ ! -s "$TASK_FILE" ]]; then
        echo -e "${YELLOW}⚠️  Žádné úkoly k označení${NC}"
        return
    fi

    show_tasks
   read -p "$(echo -e "${GREEN}${BOLD}🔢  Zadej číslo úkolu, který je hotový:${NC} ")" index


    if ! [[ "$index" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}❌  Neplatné číslo.${NC}"
        return
    fi

    total=$(wc -l < "$TASK_FILE")
    if (( index < 1 || index > total )); then
        echo -e "${RED}🚫  Úkol s tímto číslem neexistuje.${NC}"
        return
    fi

    tmp_file=$(mktemp)
    line_num=1

    while IFS= read -r line; do
        if [[ $line_num -eq $index ]]; then
            updated_line="${line/\[ \]/[x]}"
            echo "$updated_line" >> "$tmp_file"
        else
            echo "$line" >> "$tmp_file"
        fi
        ((line_num++))
    done < "$TASK_FILE"

    mv "$tmp_file" "$TASK_FILE"
    echo -e "${GREEN}🟢  Úkol č. $index označen jako dokončený.${NC}"
}

# Funkce smaže úkol podle čísla
delete_task() {
    if [[ ! -s "$TASK_FILE" ]]; then
        echo -e "${YELLOW}⚠️  Žádné úkoly ke smazání.${NC}"
        return
    fi

    show_tasks
    read -p "$(echo -e "${BOLD}🗑️  Zadej číslo úkolu, který chceš smazat:${NC} ")" index

    if ! [[ "$index" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}❌  Neplatné číslo.${NC}"
        return
    fi

    total=$(wc -l < "$TASK_FILE")
    if (( index < 1 || index > total )); then
        echo -e "${RED}🚫  Úkol s tímto číslem neexistuje.${NC}"
        return
    fi

    tmp_file=$(mktemp)
    line_num=1

    while IFS= read -r line; do
        if [[ $line_num -ne $index ]]; then
            echo "$line" >> "$tmp_file"
        fi
        ((line_num++))
    done < "$TASK_FILE"

    mv "$tmp_file" "$TASK_FILE"
    echo -e "${GREEN}🗑️  Úkol č. $index byl smazán.${NC}"
}

# Hlavní smyčka programu
main_loop() {
  while true; do
    show_menu
    read -p "Zadej volbu [1-6]: " choice
    echo
    case $choice in
      1) show_tasks ;;
      2) add_task ;;
      3) mark_task_done ;;
      4) delete_task ;;
      5) export_to_md ;;
      6) echo "Ukončuji..."; break ;;
      *) echo -e "${RED}❌  Neplatná volba, zkus znovu.${NC}" ;;
    esac
    echo
  done
}

# Spuštění hlavní smyčky
main_loop
