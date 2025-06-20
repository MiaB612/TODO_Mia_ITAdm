#!/bin/bash

# TASKMASTER - správce úkolů v terminálu

# Vytvářím soubor s úkoly = proměnná definuje soubor
TASK_FILE="tasks.txt"

# Funkce přidat úkol, zkouším i emoji
add_task() {
    read -p "Zadej popis nového úkolu: " task
    if [[ -z "$task" ]]; then
        echo "⚠️ Úkol nemůže být prázdný!"
        return
    fi

    echo "[ ] $task" >> "$TASK_FILE"
    echo "✅ Úkol přidán." 
}

# Funkce zobrazí vložené úkoly
show_tasks() {
    if [[ ! -s "$TASK_FILE" ]]; then
        echo "🤷‍♀️ Žádné úkoly k zobrazení"
        return
    fi

    echo "📋 Seznam úkolů:"
    echo "-----------------"

    local i=1
    while IFS= read -r line; do
        echo "$i) $line"
        ((i++))
    done < "$TASK_FILE"
}


# Funkce zobrazí hlavní menu 
show_menu() {
    echo "-------------------------"
    echo " TASKMASTER - SPRÁVCE ÚKOLŮ"
    echo "-------------------------"
    echo "1) Zobrazit všechny úkoly"
    echo "2) Přidat nový úkol"
    echo "3) Označit úkol jako dokončený"
    echo "4) Smazat úkol"
    echo "5) Konec"
    echo
}

#  Funkce zobrazí úkol jako odškrtnutý
mark_task_done() {
    if [[ ! -s "$TASK_FILE" ]]; then
        echo "🤷‍♀️Žádné úkoly k označení"
        return
    fi

    show_tasks
    read -p "Zadej číslo úkolu, který je hotový: " index

    if ! [[ "$index" =~ ^[0-9]+$ ]]; then
        echo "❌ Neplatné číslo."
        return
    fi

    total=$(wc -l < "$TASK_FILE")
    if (( index < 1 || index > total )); then
        echo "🚫 Úkol s tímto číslem neexistuje."
        return
    fi

    tmp_file=$(mktemp)
    line_num=1

    while IFS= read -r line; do
        if [[ $line_num -eq $index ]]; then
            updated_line="${line/\[ \]/[x]} ✅"
            echo "$updated_line" >> "$tmp_file"
        else
            echo "$line" >> "$tmp_file"
        fi
        ((line_num++))
    done < "$TASK_FILE"

    mv "$tmp_file" "$TASK_FILE"
    echo " Úkol č. $index označen jako dokončený."
}

# Funkce smaže úkol podle čísla
delete_task() {
    if [[ ! -s "$TASK_FILE" ]]; then
        echo "🤷‍♀️ Žádné úkoly ke smazání."
        return
    fi

    show_tasks
    read -p "Zadej číslo úkolu, který chceš smazat: " index

    if ! [[ "$index" =~ ^[0-9]+$ ]]; then
        echo "❌ Neplatné číslo."
        return
    fi

    total=$(wc -l < "$TASK_FILE")
    if (( index < 1 || index > total )); then
        echo "🚫 Úkol s tímto číslem neexistuje."
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
    echo "🗑️ Úkol č. $index byl smazán."
}

# Hlavní smyčka programu (vytvořím funkci pro smycku)
main_loop() {
    while true; do
        show_menu
        read -p "Zadej volbu [1-5]: " choice
        case $choice in
            1) show_tasks ;;
            2) add_task ;;
            3) mark_task_done ;;
            4) delete_task ;;
            5) echo "Ukončuji..."; break ;;
            *) echo "Neplatná volba, zkus znovu." ;;
        esac
        echo    # prázdný řádek
    done
}

# Spuštění hlavní smyčky
main_loop



