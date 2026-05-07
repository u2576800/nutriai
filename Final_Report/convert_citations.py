"""
Script to convert all plain-text in-text citations in report.typ
to proper Typst @key citations and remove the manual reference list.
"""
import re

with open(r"Final_Report/report.typ", "r", encoding="utf-8") as f:
    content = f.read()

# ── Citation mapping: "text form" → "bib key" ──────────────
# Order matters: longer/more specific patterns first to avoid partial matches
replacements = [
    # Parenthetical citations: (Author, Year)
    ("(Brankovic and Hendrie, 2025)", "@brankovic2025perspectives"),
    ("(Xie et al., 2024)", "@xie2024gut"),
    ("(Bandi et al., 2023)", "@krishna2025ai"),
    ("(Zeevi et al., 2015)", "@zeevi2015personalised"),
    ("(Ben-Yacov et al., 2021)", "@benyacov2021personalised"),
    ("(Ben-Yacov et al., 2023)", "@benyacov2023personalised"),
    ("(Bul et al., 2023)", "@bul2023ai"),
    ("(Rein et al., 2022)", "@rein2022gut"),
    ("(Jin et al., 2024)", "@jin2024gpt"),
    ("(Adams et al., 2020)", "@adams2020perspective"),
    ("(Reitmeier et al., 2020)", "@reitmeier2020handling"),
    ("(Tsolakidis et al., 2024)", "@tsolakidis2024interoperability"),
    ("(Forman et al., 2019)", "@forman2019randomized"),
    ("(Mulani et al., 2020)", "@mulani2020reinforcement"),
    ("(Sommerville, 2016)", "@sommerville2016software"),
    ("(Probul et al., 2024)", "@probul2024ai"),
    
    # Multi-citations in parentheses — replace entire group
    ("(Xie et al., 2024; Brankovic and Hendrie, 2025)", "@xie2024gut @brankovic2025perspectives"),
    ("(Brankovic and Hendrie, 2025; Probul et al., 2024)", "@brankovic2025perspectives @probul2024ai"),
    ("(Bul et al., 2023; Brankovic and Hendrie, 2025)", "@bul2023ai @brankovic2025perspectives"),
    ("(Bandi et al., 2023; Brankovic and Hendrie, 2025)", "@krishna2025ai @brankovic2025perspectives"),
    ("(Bul et al., 2023; Jin et al., 2024)", "@bul2023ai @jin2024gpt"),
    ("(Bul et al., 2023; Joshi et al., 2023)", "@bul2023ai @joshi2023digital"),
    ("(Bul et al., 2023; Ben-Yacov et al., 2021)", "@bul2023ai @benyacov2021personalised"),
    ("(Joshi et al., 2023; Bul et al., 2023)", "@joshi2023digital @bul2023ai"),
    ("(Joshi et al., 2023; Jin et al., 2024)", "@joshi2023digital @jin2024gpt"),
    ("(Zeevi et al., 2015; Joshi et al., 2023)", "@zeevi2015personalised @joshi2023digital"),
    ("(Zeevi et al., 2015; Ben-Yacov et al., 2021; Bul et al., 2023)", "@zeevi2015personalised @benyacov2021personalised @bul2023ai"),
    ("(Zeevi et al., 2015; Rein et al., 2022; Ben-Yacov et al., 2023)", "@zeevi2015personalised @rein2022gut @benyacov2023personalised"),
    ("(Zeevi et al., 2015; Ben-Yacov et al., 2021; Rein et al., 2022)", "@zeevi2015personalised @benyacov2021personalised @rein2022gut"),
    ("(Zeevi et al., 2015; Bul et al., 2023)", "@zeevi2015personalised @bul2023ai"),
    ("(Zeevi et al., 2015; Ben-Yacov et al., 2021; Joshi et al., 2023)", "@zeevi2015personalised @benyacov2021personalised @joshi2023digital"),
    ("(Ben-Yacov et al., 2021; Joshi et al., 2023)", "@benyacov2021personalised @joshi2023digital"),
    ("(Ben-Yacov et al., 2021; Bul et al., 2023)", "@benyacov2021personalised @bul2023ai"),
    ("(Amershi et al., 2019; Jin et al., 2024)", "@amershi2019software @jin2024gpt"),
    ("(Amershi et al., 2019)", "@amershi2019software"),
    ("(Reitmeier et al., 2020; Ben-Yacov et al., 2021)", "@reitmeier2020handling @benyacov2021personalised"),
    ("(Reitmeier et al., 2020; Tsolakidis et al., 2024)", "@reitmeier2020handling @tsolakidis2024interoperability"),
    ("(Reitmeier et al., 2020; Probul et al., 2024)", "@reitmeier2020handling @probul2024ai"),
    ("(Reitmeier et al., 2020; Adams et al., 2020)", "@reitmeier2020handling @adams2020perspective"),
    ("(Özdemir and Kolker, 2016; Adams et al., 2020)", "@ozdemir2016precision @adams2020perspective"),
    ("(Özdemir & Kolker, 2016; Adams et al., 2020)", "@ozdemir2016precision @adams2020perspective"),
    ("(Adams et al., 2020; Brankovic and Hendrie, 2025)", "@adams2020perspective @brankovic2025perspectives"),
    ("(Forman et al., 2019; Mulani et al., 2020)", "@forman2019randomized @mulani2020reinforcement"),
    ("(Mulani et al., 2020; Brankovic and Hendrie, 2025)", "@mulani2020reinforcement @brankovic2025perspectives"),
    ("(Sommerville, 2016; Amershi et al., 2019)", "@sommerville2016software @amershi2019software"),
    ("(Human Microbiome Project Consortium, 2012; Zeevi et al., 2015)", "@hmp2012structure @zeevi2015personalised"),
    ("(Özdemir and Kolker, 2016)", "@ozdemir2016precision"),
    ("(Özdemir & Kolker, 2016)", "@ozdemir2016precision"),
    ("(Van Rossum and Drake, 2009)", "@vanrossum2009python"),
    ("(Abadi et al., 2016)", "@abadi2016tensorflow"),
    ("(Lundberg and Lee, 2017)", "@lundberg2017unified"),
    ("(Human Microbiome Project Consortium, 2012)", "@hmp2012structure"),
    ("(Joshi et al., 2023)", "@joshi2023digital"),
    
    # Narrative citations: Author (Year) — within sentences
    ("Brankovic and Hendrie (2025)", "#cite(<brankovic2025perspectives>, form: \"prose\")"),
    ("Bul et al. (2023)", "#cite(<bul2023ai>, form: \"prose\")"),
    ("Jin et al. (2024)", "#cite(<jin2024gpt>, form: \"prose\")"),
    ("Zeevi et al. (2015)", "#cite(<zeevi2015personalised>, form: \"prose\")"),
    ("Ben-Yacov et al. (2021)", "#cite(<benyacov2021personalised>, form: \"prose\")"),
    ("Ben-Yacov et al. (2023)", "#cite(<benyacov2023personalised>, form: \"prose\")"),
    ("Rein et al. (2022)", "#cite(<rein2022gut>, form: \"prose\")"),
    ("Joshi et al. (2023)", "#cite(<joshi2023digital>, form: \"prose\")"),
    ("Adams et al. (2020)", "#cite(<adams2020perspective>, form: \"prose\")"),
    ("Reitmeier et al. (2020)", "#cite(<reitmeier2020handling>, form: \"prose\")"),
    ("Probul et al. (2024)", "#cite(<probul2024ai>, form: \"prose\")"),
    ("Amershi et al. (2019)", "#cite(<amershi2019software>, form: \"prose\")"),
    ("Sommerville (2016)", "#cite(<sommerville2016software>, form: \"prose\")"),
    ("Forman et al. (2019)", "#cite(<forman2019randomized>, form: \"prose\")"),
]

# Sort by length descending so longer patterns match first
replacements.sort(key=lambda x: len(x[0]), reverse=True)

count = 0
for old, new in replacements:
    occurrences = content.count(old)
    if occurrences > 0:
        content = content.replace(old, new)
        count += occurrences
        print(f"  {occurrences}x  {old[:60]}...")

print(f"\nTotal replacements: {count}")

# ── Remove the manual reference list section ─────────────────
# Find the manual reference list and remove it (keep #bibliography)
marker_start = "= Reference List <references>"
marker_end = "#bibliography("

start_idx = content.find(marker_start)
bib_idx = content.find(marker_end)

if start_idx != -1 and bib_idx != -1:
    # Keep everything before the "= Reference List" heading
    # and everything from #bibliography onwards
    # But we need to keep the heading numbering reset
    before = content[:start_idx]
    from_bib = content[bib_idx:]
    
    # Insert proper section with just the bibliography command
    content = before + "= Reference List <references>\n\n" + from_bib
    print("\n✅ Removed manual reference list, kept #bibliography command")

with open(r"Final_Report/report.typ", "w", encoding="utf-8") as f:
    f.write(content)

print("✅ Done! File updated.")
