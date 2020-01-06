# Babel New Workflow

## Objective
**Implement a solution to for translator to localize (translate) software**

## Overall Workflow
1. Export from sisulizer into tab separated text file including all languages. 
2. Import into database.
3. Make changes to translation through `webapp` <-> `api` <-> `database`.
4. Export a txt file with format from db with format 
  
    `[Context\tOriginal\tzh\t]`

5. Import into sisulizer (cli unable to import from db).
6. Build .bpl files.

---
### Export from Sisulizer to a text file:
```
slmake export z:\core-export.txt -format:1 -lang:zh;ms;id;lo;my;th;km;ar-AE;zh.tra -escape:1 -readonly:false -nobom sql-core.slp 
```

### Import into MariaDB from text file:
```sql
LOAD DATA LOCAL INFILE 'core-export.txt'
INTO TABLE context
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
(context, original);
```

### Import from a text file into Sisulizer:
> Matched by Context, Always overwrite
```
slmake import z:\core-export.txt -tmarked:2 -textdef:z:\Definition.sli -method:0 -overwrite:3 -lang:zh;ms;id;lo;my;th;km;ar-AE;zh.tra sql-core.slp
``` 

**Definition.sli:**
```xml
<?xml version="1.0" encoding="utf-8"?>
<textdefinition version="4.0.370" name="TextDef1" purpose="cpImport" detectfileformat="0" fileformat="tffUtf8">
  <item type="ctContext" after="\t"/>
  <item type="ctOriginal" after="\t" escape="seCpp"/>
  <item type="ctText" after="\t" escape="seCpp" language="zh"/>
  <item type="ctText" after="\t" escape="seCpp" language="ms"/>
  <item type="ctText" after="\t" escape="seCpp" language="id"/>
  <item type="ctText" after="\t" escape="seCpp" language="lo"/>
  <item type="ctText" after="\t" escape="seCpp" language="my"/>
  <item type="ctText" after="\t" escape="seCpp" language="th"/>
  <item type="ctText" after="\t" escape="seCpp" language="km"/>
  <item type="ctText" after="\t" escape="seCpp" language="ar-AE"/>
  <item type="ctText" after="\r\n|\z" escape="seCpp" language="zh.tra"/>
</textdefinition>
```


