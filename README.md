# xmlcomp
Compare two XML documents
------------------------------------------------------------------------
**xmlcomp** is an XSLT stylesheet you can run against two XML documents to determine structural and textual content difference. 

**xmlcomp** will only report on elements found in the first input file `xml1.xml`, but which are either missing or have different content in the second file `xml2.xml`. In order to find **all** differences between `xml1.xml` and `xml2.xml`, you will need to run `xmlcomp.sh` twice - once with `xml1.xml` as the first file argument and then again with `xml2.xml` as the 1st file and `xml1.xml` as the 2nd one.

Prerequisites
-------------
- xsltproc
- bash

Features
--------
- compare XML element structure
  + Report missing element only
  + Report also element strict position
- Report missing attributes
- Report textual `text()` differences

Usage
-----
     $ ./xmlcomp.sh
     Usage: ./xmlcomp.sh [-t] [-p ELEMENT-NAME[,..]|*] <xml1> <xml2>

        options:
        -a  compare attributes
        -t  diff element content - otherwise only missing elements will be reported
        -p  comma-separated list of element names which should be
            compared with strict positioning. 
            The default is not to care about the position of 
            a child element under its parent, but either it exists or not. 
            If the value for -p is '*', then all document elements
            will be compared with strict positioning turned on

Examples
--------
Given the following XML files as input:
- original.xml:
    ```xml
    <root>
        <oldname>old</oldname>
        <newname>new</newname>
        <with-attribute attr1="1" missing-attr="2" attr-diff="original text"/>

        <array>
            <item>
                <a>a</a>
                <b>b</b>
            </item>
            <item>
                <a>a</a>
                <b>b</b>
            </item>
            <item>
                <a>a</a>
                <b>b</b>
            </item>
        </array>
    </root>
    ```
- new.xml:
    ```xml
    <root>
        <newname>new</newname>
        <with-attribute attr1="1" attr-diff="new text"/>

        <array>
            <item>
                <a>a</a>
                <b>b</b>
            </item>
            <item>
                <a>a</a>
            </item>
            <item>
                <a>b</a>
                <c>b</c>
            </item>
        </array>
    </root>
    ```

-------------
- compare element structure - ignore element positioning:

        $ ./xmlcomp.sh original.xml new.xml
            error: missing /root/oldname
- compare element structure - strict element positioning for `item`:
  
        $ ./xmlcomp.sh -p item original.xml new.xml
            error: missing /root/oldname
            error: missing /root/array/item[2]/b
            error: missing /root/array/item[3]/b

- compare element structure including attributes:
  
        $ ./xmlcomp.sh -a original.xml new.xml
            error: missing /root/oldname
            error: missing /root/with-attribute/@missing-attr

- compare element structure including strict positioning, attributes and element text:
  
        $ ./xmlcomp.sh -p item -t -a original.xml new.xml        
            error: missing /root/oldname
            error: missing /root/with-attribute/@missing-attr
            warning: content /root/with-attribute/@attr-diff:
            --- original text
            +++ new text
            error: missing /root/array/item[2]/b
            warning: content /root/array/item[3]/a:
            --- a
            +++ b
            error: missing /root/array/item[3]/b

