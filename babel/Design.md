# Backend Design
## Database Version Control, use epoch (UTC+0) as version id

| Device | BackEnd | Action              |
|--------|---------|---------------------|
| n      | n       | OK, good to resolve |
| n      | n-m     | n/a                 |
| n      | n+m     | resolved            |

## Entries Version Control

| Device | BackEnd | Action                                  |
|--------|---------|-----------------------------------------|
| n      | n       | OK, good to resolve                     |
| n      | n       | conflict, feedback with entries history |
| n      | n+m     | conflict, feedback with entries history |

>Device epoch : Use device timestamp (UTC+0), if epoch value > entries epoch value, then can save, else entries epoch+1

---

## Database Design:
### Tables

`Context`
```
id       autoinc (primary key)
epoch    integer
appid    varchar
context  varchar (UTF8)  - unique
original varchar (UTF8)
```
When developer update new context:

| DB context | Application Context | Action |
|------------|---------------------|--------|
| -          | Yes                 | Insert |
| Yes        | Yes (same)          | n/a    |
| Yes        | Yes (diff)          | Update |
| Yes        | -                   | Delete |


`Translation`
```
id          autoinc     (primary key)
context_id  int64       (foreign key: context.id)
lang_id     varchar     (developer defined)
translation varchar
LastUpdated epoch
```
| Device | BackEnd    | Action                                                       |
|--------|------------|--------------------------------------------------------------|
| Yes    | No         | Insert                                                       |
| Yes    | Yes (same) | n/a                                                          |
| Yes    | Yes (diff) | nobody update,  post transation_history, update              |
| Yes    | Yes (diff) | other user update, conflict, feed back to device and resolve |

**if empty string, consider as empty row -> let user update directly**

`Translation_History`
```
id
user_id             
translation_epoch
context_id
lang_id
translation
```

`Dictionary`
```
id          autoinc
lang_id     varchar
original    varchar
translation varchar
```

`Users`
```
id          autoinc
email       varchar()
Name        varchar()
lang_ids    varchar()   e.g.: zh-CN; th; MS
```

---
## Old Api Design
 Using the api:

To retrieve all existing translation (format of = [context original zh ms vi id lo ar-ae th mo mo-at my km]):  

	- curl https://babel.sql.com.my/translation (deprecated)
	- new: curl https://babel.sql.com.my/sisulizer/{app-id}
    - new: curl https://babel.sql.com.my/sisulizer/textdef (return .sli xml content)

To insert or update contexts:

	- curl -X POST --data-binary "@.txt" https://babel.sql.com.my/sisulizer/{appid}
	*appid : [account, core, bank, dataimport, runtime]

1. define xslt to translate .slp file to tab separated .txt
2. how to transform xml + xslt = .txt
