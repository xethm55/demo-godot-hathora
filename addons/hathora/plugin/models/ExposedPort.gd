extends Resource

# THIS FILE WAS AUTOMATICALLY GENERATED by the OpenAPI Generator project.
# For more information on how to customize templates, see:
# https://openapi-generator.tech
# https://github.com/OpenAPITools/openapi-generator/tree/master/modules/openapi-generator/src/main/resources/gdscript
# The OpenAPI Generator Community, © Public Domain, 2022

# ExposedPort Model
# Connection information to an exposed port on an active process.


# Required: True
# isArray: false
@export var transportType: String:
	set(value):
		__transportType__was__set = true
		transportType = value
var __transportType__was__set := false

# Required: True
# isArray: false
@export var port: int:
	set(value):
		__port__was__set = true
		port = value
var __port__was__set := false

# Required: True
# isArray: false
@export var host: String = "":
	set(value):
		__host__was__set = true
		host = value
var __host__was__set := false

# Required: True
# isArray: false
@export var name: String = "":
	set(value):
		__name__was__set = true
		name = value
var __name__was__set := false


func bzz_collect_missing_properties() -> Array:
	var bzz_missing_properties := Array()
	if not self.__transportType__was__set:
		bzz_missing_properties.append("transportType")
	if not self.__port__was__set:
		bzz_missing_properties.append("port")
	if not self.__host__was__set:
		bzz_missing_properties.append("host")
	if not self.__name__was__set:
		bzz_missing_properties.append("name")
	return bzz_missing_properties


func bzz_normalize() -> Dictionary:
	var bzz_dictionary := Dictionary()
	if self.__transportType__was__set:
		bzz_dictionary["transportType"] = self.transportType
	if self.__port__was__set:
		bzz_dictionary["port"] = self.port
	if self.__host__was__set:
		bzz_dictionary["host"] = self.host
	if self.__name__was__set:
		bzz_dictionary["name"] = self.name
	return bzz_dictionary


# Won't work for JSON+LD
static func bzz_denormalize_single(from_dict: Dictionary):
	var me := new()
	if from_dict.has("transportType"):
		me.transportType = from_dict["transportType"]
	if from_dict.has("port"):
		me.port = from_dict["port"]
	if from_dict.has("host"):
		me.host = from_dict["host"]
	if from_dict.has("name"):
		me.name = from_dict["name"]
	return me


# Won't work for JSON+LD
static func bzz_denormalize_multiple(from_array: Array):
	var mes := Array()
	for element in from_array:
		if element is Array:
			mes.append(bzz_denormalize_multiple(element))
		elif element is Dictionary:
			# TODO: perhaps check first if it looks like a match or an intermediate container
			mes.append(bzz_denormalize_single(element))
		else:
			mes.append(element)
	return mes

