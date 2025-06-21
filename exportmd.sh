#!/bin/bash

export_to_md() {
    if [[ ! -s "$TASK_FILE" ]]; then
        echo -e "${YELLOW}🤷‍♀️ Žádné úkoly k exportu.${NC}"
        return
    fi

    MD_FILE="tasks.md"

    {
        echo "# Seznam úkolů"
        echo
        local i=1
        while IFS= read -r line; do
            md_line=$(echo "$line" | sed -e 's/^\[ \]/- [ ]/' -e 's/^\[x\]/- [x]/')
            echo "$i. $md_line"
            ((i++))
        done < "$TASK_FILE"
    } > "$MD_FILE"

    echo -e "${GREEN}✅  Úkoly byly exportovány do souboru ${MD_FILE}.${NC}"
}
