#!/usr/bin/python
import xml.dom.minidom
import sys

xml = xml.dom.minidom.parse(sys.argv[1]) # or xml.dom.minidom.parseString(xml_string)
pretty_xml_as_string = xml.toprettyxml()
print pretty_xml_as_string
