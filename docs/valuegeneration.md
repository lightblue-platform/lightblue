# Value generator

There is a need for lightblue to automatically generate required values when not specified. This became apparent during migration from legacy datastore using numeric IDs, incompatible with random strings which lightblue generates for uids. More control is needed over ID generation.

### Use cases
* Generate string or numeric IDs when inserting new entities, depending on the client requirements.
* Generate creation and modification date when inserting new entities.

### Information needed to generate a value
Generated or not, each field needs a type. Generation can be done using different methods and those methods can accept parameters. For clarity's sake, I would generate the value only for insert operations and only when the value is not specified by the client (that means modification date on update still has to be refreshed explicitly by client). Generation makes sense only for required fields, so when generator is specified, ligtblue should implicitly make the field required.

### Proposed metadata syntax

Associating generators with fields in the schema:

String ID:
```
"_id": {
  "constraints": {
    "identity": true
  },
  "generator": "stringId",
  "description": "The identifier of this entity.",
  "type": "string"
}
```

Numeric ID:
```
"_id": {
  "constraints": {
    "identity": true
  },
  "generator": "longId",
  "description": "The identifier of this entity.",
  "type": "integer"
}
```

Creation date:
```
"creationDate": {
  "constraints": {
    "required": true
  },
  "generator": "currentDate",  
  "description": "Time of creation",
  "type": "date"
}
```
### Backwards compatibility

Uid field type will be superseded by stringId value generator, but it has to be kept for backwards compatibility. 

### More ideas

Custom generators defined in entityInfo:
```
entityInfo: {

  "valueGenerators": [
    {
      "type": "randomString"
      "name": "myStringId",
      "properties": {
        "length": 12
      }
    },
    {
      "type": "randomInteger"
      "name": "myLongId",
      "properties": {
        "min": 0,
        "max": "MAX_LONG" # 2^63-1
      }      
    }
  ]

}
```

This is how custom generators can be defined, though the commonly used ones - stringId, longId, currentDate - should be available by default. Otherwise the same valueGenerators block would be defined in each entity.

Further ideas:
* define more generator types, e.g. sequenceInteger or randomConstant,
* allow generator properties to be overridden in the schema,
* js generator type, which would accept a javascript snippet as a parameter and use it to generate the value.
