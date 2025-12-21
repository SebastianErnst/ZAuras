// ==UserScript==
// @name         Turtle WoW Spell Scraper by ID
// @namespace    http://tampermonkey.net/
// @version      2025-12-18
// @description  Scrape all spells by iterating through spell IDs
// @author       You
// @match        https://database.turtle-wow.org/*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=turtle-wow.org
// @grant        GM_download
// ==/UserScript==

(async function () {
    'use strict';

    let allSpells = [];
    let currentId = 1;
    let consecutiveNotFound = 0;
    const maxConsecutiveNotFound = 50;
    const maxSpells = 10; // Test limit
    
    console.log("Start scraping spells by ID...");

    while (consecutiveNotFound < maxConsecutiveNotFound && allSpells.length < maxSpells) {
        console.log(`Checking spell ID: ${currentId}`);
        
        try {
            const spellData = await getSpellInfoById(currentId);
            
            if (spellData && spellData.name) {
                console.log(`✓ Found spell ${currentId}: ${spellData.name} (Rank ${spellData.rank})`);
                consecutiveNotFound = 0;
                
                allSpells.push({
                    id: currentId,
                    name: spellData.name,
                    icon: spellData.icon,
                    castTime: spellData.castTime,
                    duration: spellData.duration,
                    cost: spellData.cost,
                    resource: spellData.resource,
                    minRange: spellData.minRange,
                    maxRange: spellData.maxRange,
                    cooldown: spellData.cooldown,
                    school: spellData.school,
                    dispelType: spellData.dispelType,
                    rank: spellData.rank
                });
            } else {
                console.log(`✗ Spell ${currentId} not found (${consecutiveNotFound + 1}/${maxConsecutiveNotFound})`);
                consecutiveNotFound++;
            }
        } catch (error) {
            console.log(`✗ Error fetching spell ${currentId}: ${error.message}`);
            consecutiveNotFound++;
        }
        
        currentId++;
        await sleep(100); // Small delay to avoid hammering the server
    }

    console.log(`Scraping complete! Found ${allSpells.length} spells.`);
    
    GM_download({
        url: "data:text/plain;charset=utf-8," + encodeURIComponent(buildLuaMappingFromSpells(allSpells)),
        name: "AllSpellsByID.txt",
    });
    console.log("AllSpellsByID.txt generated!");

    function sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }


    async function getSpellInfoById(id) {
        const url = "https://database.turtle-wow.org/?spell=" + id;
        const response = await fetch(url);
        const html = await response.text();
        const parser = new DOMParser();
        const doc = parser.parseFromString(html, "text/html");
        
        // Check if spell exists (check for spell name)
        const spellName = doc.querySelector("#main .tooltip th b");
        if (!spellName) {
            return null; // Spell doesn't exist
        }
        
        let data = {}
        
        // Get spell name (remove rank from name)
        let fullName = doc.querySelector("h1").textContent.trim();
        // Remove "(Rank X)" from the name
        data.name = fullName.replace(/\s*\(Rank\s+\d+\)\s*/i, "").trim();
        
        // Get icon
        const iconElement = doc.querySelector(".iconlarge");
        if (iconElement) {
            data.icon = iconElement.style.backgroundImage.split("\"")[1].split("/")[3].split(".")[0];
        } else {
            data.icon = "inv_misc_questionmark";
        }

        //castTime = 1.5,
        data.castTime = doc.querySelectorAll("#spelldetails tbody > tr:nth-child(4) td:nth-child(2)")[1].textContent.trim();
        if (data.castTime === 'Instant' || data.castTime === 'Channeled') {
            data.castTime = 0;
        } else {
            data.castTime = data.castTime.split(" ")[0];
        }
        //duration = 18,
        data.duration = doc.querySelectorAll("#spelldetails tbody > tr:nth-child(2) td:nth-child(2)")[0].textContent.trim();
        if (data.duration !== 'n/a') {
            data.duration = data.duration.split(" ")[0];
        } else {
            data.duration = 0;
        }
        //cost = 340,
        //resource = "mana",
        data.cost = doc.querySelectorAll("#spelldetails tbody > tr:nth-child(2) td:nth-child(2)")[1].textContent.trim();
        if (data.cost.includes("%")) {
            let splitString = data.cost.split(" ")
            data.cost = splitString[0].substring(0, splitString[0].length - 1);
            data.resource = splitString[1] + " " + splitString[2];
        } else if (data.cost === 'None') {
            data.cost = 0;
            data.resource = ""
        } else {
            let splitString = data.cost.split(" ")
            data.cost = splitString[0];
            data.resource = splitString[1];
        }
        //minRange = 0,
        //maxRange = 30,
        data.range = doc.querySelectorAll("#spelldetails tbody > tr:nth-child(3) td:nth-child(2)")[1].textContent.trim().split(" ")[0].split(".")[0];
        if (data.range.includes("-")) {
            let rangeParts = data.range.split("-");
            data.minRange = rangeParts[0];
            data.maxRange = rangeParts[1];
        } else {
            data.minRange = 0;
            data.maxRange = data.range;
        }
        //cooldown = 0,
        data.cooldown = doc.querySelectorAll("#spelldetails tbody > tr:nth-child(5) td:nth-child(2)")[1].textContent.trim();
        if (data.cooldown !== 'n/a') {
            data.cooldown = data.cooldown.split(" ")[0];
        } else {
            data.cooldown = 0;
        }
        //school = "Shadow",
        data.school = doc.querySelectorAll("#spelldetails tbody > tr:nth-child(3) td:nth-child(2)")[0].textContent.trim();
        //dispelType = "Magic"
        data.dispelType = doc.querySelectorAll("#spelldetails tbody > tr:nth-child(5) td:nth-child(2)")[0].textContent.trim();
        if (data.dispelType === 'n/a') {
            data.dispelType = "";
        }
        //rank
        data.rank = doc.querySelector("#main .tooltip th b");
        if (data.rank !== null) {
            data.rank = data.rank.textContent.trim();
            if (data.rank.includes("Rank")) {
                data.rank = data.rank.split("Rank")[1].trim();
            } else {
                data.rank = 1;
            }
        } else {
            data.rank = 1;
        }
        
        return data;
    }
    function buildLuaMappingFromSpells(allSpells) {
        // 1) Gruppieren nach Name
        const groups = {};
        for (const s of allSpells) {
            if (!groups[s.name]) {
                groups[s.name] = {
                    icon: s.icon,
                    ranks: []
                };
            }
            groups[s.name].ranks.push(s);
        }

        // 2) Sortieren nach rank (als Zahl)
        for (const name in groups) {
            groups[name].ranks.sort((a, b) => Number(a.rank) - Number(b.rank));
        }

        // 3) Lua-String aufbauen
        let out = "";

        for (const name in groups) {
            const spell = groups[name];
            const ranks = spell.ranks;
            const maxRank = ranks.length;

            out += `    ["${name}"] = {\n`;
            out += `        icon = "${spell.icon}",\n`;
            out += `        ranks = {\n`;
            out += `            maxRank = ${maxRank},\n`;

            for (let i = 0; i < ranks.length; i++) {
                const r = ranks[i];
                const rankIndex = i + 1;

                out += `            [${rankIndex}] = {\n`;
                out += `                id = ${r.id},\n`;
                out += `                castTime = ${r.castTime},\n`;
                out += `                duration = ${r.duration},\n`;
                out += `                cost = ${r.cost},\n`;
                out += `                resource = "${r.resource}",\n`;
                out += `                minRange = ${r.minRange},\n`;
                out += `                maxRange = ${r.maxRange},\n`;
                out += `                cooldown = ${r.cooldown},\n`;
                out += `                school = "${r.school}",\n`;
                out += `                dispelType = "${r.dispelType}"\n`;
                out += `            },\n`;
            }

            out += `        }\n`;
            out += `    },\n`;
        }

        return out;
    }

})();