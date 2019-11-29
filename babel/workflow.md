# Babel New Workflow

## Objective
**Implement a solution to for translator to localize (translate) software**

## Overall Workflow
1. Export from sisulizer into tab separated text file including all languages. 
2. Import into database.
3. Make changes to translation through webapp <-> api <-> database.
4. Import into sisulizer (through database or text file).
5. Build .bpl files.

---
### Export from Sisulizer to a text file:
```
slmake export z:\core-export.txt -format:1 -lang:`zh;ms;id;lo;my;th;km;ar-AE;zh.tra -escape:1 -readonly:false -nobom sql-core.slp 
```

### Import into MariaDB from text file:
```sql
LOAD DATA LOCAL INFILE 'translation.txt'
INTO TABLE context
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\r\n'
(context, original);
```

### Import from a text file into Sisulizer:
```
slmake import r:\core-zh-cn.txt -tmarked:2 -textdef:Definition.sli -method:1 -overwrite:3 sql-core.slp -lang:zh;ms;vi;id;lo;ar-ae;th;mo;mo-at;my;km
``` 

**Definition.sli:**
```xml
<?xml version="1.0" encoding="utf-8"?>
<textdefinition version="4.0.370" name="TextDef1" purpose="cpImport" detectfileformat="0" fileformat="tffUtf8">
  <item type="ctContext" after="\t"/>
  <item type="ctOriginal" after="\t" escape="seCpp"/>
  <item type="ctText" after="\t" escape="seCpp" language="zh"/>
  <item type="ctText" after="\r\n|\z" escape="seCpp" language="zh.tra"/>
</textdefinition>
```


