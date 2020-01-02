
# EmailGen - Email Generation from Bing using LinkedIn Dorks 
---

In our research, bing is very liberal when scraping with mechanize. Using well-known google dorks, we can obtain all the names of employees at a company and using a predefined email format, we can mould these into valid (usually) email addresses.

---
# Usage

## EmailGen
EmailGen is for Email generation, similar to https://github.com/byt3bl33d3r/SprayingToolkit, but fully headless, no more mitmdump, and no more clicking through 27 pages of Google, (no disrespect byt3bl33d3r :)

```
./EmailGen.rb -c "Company, Inc" -d "company.com" -f "{f}{last}@{domain}" -o company_emails.txt
```

If you load tokens.rb with your hunter api key, you can just use the -d parameter and it will pull the rest automatically.

Easy as that!


# Screenshots
---
![](https://raw.githubusercontent.com/navisecdelta/EmailGen/master/screenshots/emailgen.png)

