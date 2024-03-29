# WARNING
I won't provide assistance with the below methods. I tried to keep the instructions as simple as possible, but they are still fairly complex.

# You will need the following tools:
1. tes3cmd: https://github.com/john-moonsugar/tes3cmd/releases
2. notepad++ or equivalent https://notepad-plus-plus.org/downloads/
3. Tes3 Construction Set (Quests Only)
4. Libre Office Calc or equivalent (Quests Only) https://www.libreoffice.org/discover/calc/

# Dumping Data
1. you should have tes3cmd in the same folder as the esm/esp files you're trying to dump data from
2. Run the listed commands from a command prompt (type cmd in explorer and hit enter):

- Creature json
`tes3cmd dump --type CREA --no-quote --no-banner --format "  \"%id%\": {\"level\": %lev%}," *.esm >> creature_levels.json`
- If you have additional .esp files that add creatures:
`tes3cmd dump --type CREA --no-quote --no-banner --format "  \"%id%\": {\"level\": %lev%}," *.esp >> creature_levels.json`

- NPC json
`tes3cmd dump --type npc_ --no-quote --no-banner --format "  \"%id%\": {\"level\": %level%}," *.esm >> npc_levels.json`
- If you have additional .esp files that add npcs:
`tes3cmd dump --type npc_ --no-quote --no-banner --format "  \"%id%\": {\"level\": %level%}," *.esp >> npc_levels.json`

- book json
`tes3cmd dump --type book --match Scroll:\(No\) --no-quote --no-banner --format "  \"%id%\": {\"value\": %value%}," *.esm >> vanilla_books.json`
- If you have additional .esp files that add books:
`tes3cmd dump --type book --match Scroll:\(No\) --no-quote --no-banner --format "  \"%id%\": {\"value\": %value%}," *.esp >> vanilla_books.json`

# Additional Formatting for EACH json:
1. Add a newline at the begining with one '{'
2. delete the ',' from the last line
3. Add a '}' to the final line (your final line should just be a '}')
4. Make all text lowercase, if using notepad++ use Ctrl+A then Ctrl+U

# Quests
1. Load active plugins in Construction set
2. File -> Export Data -> All Dialogue
3. Open with excel or equivalent
4. Add a new row at the top, Label cell D1 as "type"
5. Sort by this column, delete all rows where this isn't "Journal"
6. Delete columns A -> C, F, G, I -> AP, AR, AS, AT
7. Label your Top Row: type, quest, index, flags
8. Sort by flags column
9. Delete all rows where flags is not Q010 (And your label row obviously)
10. Delete colums A & D ("Type" & "Flags")
11. You should have two columns, "quest" and "index"
12. Make the quest column all lowercase
13. In column C (should be empty) use the formula =CONCAT(A2,"_",B2), re-label this column quest
14. label column D isend, copy the value "true" (this should be text, not a boolean) to every cell in this column
15. copy paste column C and D to a new sheet (use the "text only" special paste), delete the old sheet
16. Save this as a csv
17. pick your favorite csv to json converter (https://csvjson.com/csv2json for example) and run it through there
18. Format as a "hash"

tes3cmd docs: https://github.com/john-moonsugar/tes3cmd/wiki/tes3cmd-command-line-documentation