extends Resource

const ContainerPort = preload("../models/ContainerPort.gd")
const DeploymentEnvInner = preload("../models/DeploymentEnvInner.gd")

# THIS FILE WAS AUTOMATICALLY GENERATED by the OpenAPI Generator project.
# For more information on how to customize templates, see:
# https://openapi-generator.tech
# https://github.com/OpenAPITools/openapi-generator/tree/master/modules/openapi-generator/src/main/resources/gdscript
# The OpenAPI Generator Community, © Public Domain, 2022

# Deployment Model
# A deployment object represents a version of your application and it's metadata.


# Required: True
# isArray: true
@export var env: Array:
	set(value):
		__env__was__set = true
		env = value
var __env__was__set := false

# Governs how many [rooms](https://hathora.dev/docs/concepts/hathora-entities#room) can be scheduled in a process.
# Required: True
# isArray: false
@export var roomsPerProcess: int:
	set(value):
		__roomsPerProcess__was__set = true
		roomsPerProcess = value
var __roomsPerProcess__was__set := false

# Required: True
# isArray: false
@export var planName: String:
	set(value):
		__planName__was__set = true
		planName = value
var __planName__was__set := false

# Required: True
# isArray: true
@export var additionalContainerPorts: Array:
	set(value):
		__additionalContainerPorts__was__set = true
		additionalContainerPorts = value
var __additionalContainerPorts__was__set := false

# Required: True
# isArray: false
@export var defaultContainerPort: ContainerPort:
	set(value):
		__defaultContainerPort__was__set = true
		defaultContainerPort = value
var __defaultContainerPort__was__set := false

# Required: True
# isArray: false
@export var transportType: String:
	set(value):
		__transportType__was__set = true
		transportType = value
var __transportType__was__set := false

# /!.  DEPRECATED
# Required: True
# isArray: false
@export var containerPort: int:
	set(value):
		if str(value) != "":
			#Ignoring this warning
			#push_warning("Deployment: property `containerPort` is deprecated.")
			pass
		__containerPort__was__set = true
		containerPort = value
var __containerPort__was__set := false

#       (but it's actually a DateTime ; no timezones support in Gdscript)
# Required: True
# isArray: false
@export var createdAt: String:
	set(value):
		__createdAt__was__set = true
		createdAt = value
var __createdAt__was__set := false

# Email address.
# Required: True
# isArray: false
@export var createdBy: String = "":
	set(value):
		__createdBy__was__set = true
		createdBy = value
var __createdBy__was__set := false

# Required: True
# isArray: false
@export var requestedMemoryMB: int:
	set(value):
		__requestedMemoryMB__was__set = true
		requestedMemoryMB = value
var __requestedMemoryMB__was__set := false

# Required: True
# isArray: false
@export var requestedCPU: int:
	set(value):
		__requestedCPU__was__set = true
		requestedCPU = value
var __requestedCPU__was__set := false

# System generated id for a completed deployment. Increments by 1.
# Required: True
# isArray: false
@export var deploymentId: int:
	set(value):
		__deploymentId__was__set = true
		deploymentId = value
var __deploymentId__was__set := false

# System generated id for a build. Increments by 1.
# Required: True
# isArray: false
@export var buildId: int:
	set(value):
		__buildId__was__set = true
		buildId = value
var __buildId__was__set := false

# System generated unique identifier for an application.
# Required: True
# isArray: false
@export var appId: String = "":
	set(value):
		__appId__was__set = true
		appId = value
var __appId__was__set := false


func bzz_collect_missing_properties() -> Array:
	var bzz_missing_properties := Array()
	if not self.__env__was__set:
		bzz_missing_properties.append("env")
	if not self.__roomsPerProcess__was__set:
		bzz_missing_properties.append("roomsPerProcess")
	if not self.__planName__was__set:
		bzz_missing_properties.append("planName")
	if not self.__additionalContainerPorts__was__set:
		bzz_missing_properties.append("additionalContainerPorts")
	if not self.__defaultContainerPort__was__set:
		bzz_missing_properties.append("defaultContainerPort")
	if not self.__transportType__was__set:
		bzz_missing_properties.append("transportType")
	if not self.__containerPort__was__set:
		bzz_missing_properties.append("containerPort")
	if not self.__createdAt__was__set:
		bzz_missing_properties.append("createdAt")
	if not self.__createdBy__was__set:
		bzz_missing_properties.append("createdBy")
	if not self.__requestedMemoryMB__was__set:
		bzz_missing_properties.append("requestedMemoryMB")
	if not self.__requestedCPU__was__set:
		bzz_missing_properties.append("requestedCPU")
	if not self.__deploymentId__was__set:
		bzz_missing_properties.append("deploymentId")
	if not self.__buildId__was__set:
		bzz_missing_properties.append("buildId")
	if not self.__appId__was__set:
		bzz_missing_properties.append("appId")
	return bzz_missing_properties


func bzz_normalize() -> Dictionary:
	var bzz_dictionary := Dictionary()
	if self.__env__was__set:
		bzz_dictionary["env"] = self.env
	if self.__roomsPerProcess__was__set:
		bzz_dictionary["roomsPerProcess"] = self.roomsPerProcess
	if self.__planName__was__set:
		bzz_dictionary["planName"] = self.planName
	if self.__additionalContainerPorts__was__set:
		bzz_dictionary["additionalContainerPorts"] = self.additionalContainerPorts
	if self.__defaultContainerPort__was__set:
		bzz_dictionary["defaultContainerPort"] = self.defaultContainerPort
	if self.__transportType__was__set:
		bzz_dictionary["transportType"] = self.transportType
	if self.__containerPort__was__set:
		bzz_dictionary["containerPort"] = self.containerPort
	if self.__createdAt__was__set:
		bzz_dictionary["createdAt"] = self.createdAt
	if self.__createdBy__was__set:
		bzz_dictionary["createdBy"] = self.createdBy
	if self.__requestedMemoryMB__was__set:
		bzz_dictionary["requestedMemoryMB"] = self.requestedMemoryMB
	if self.__requestedCPU__was__set:
		bzz_dictionary["requestedCPU"] = self.requestedCPU
	if self.__deploymentId__was__set:
		bzz_dictionary["deploymentId"] = self.deploymentId
	if self.__buildId__was__set:
		bzz_dictionary["buildId"] = self.buildId
	if self.__appId__was__set:
		bzz_dictionary["appId"] = self.appId
	return bzz_dictionary


# Won't work for JSON+LD
static func bzz_denormalize_single(from_dict: Dictionary):
	var me := new()
	if from_dict.has("env"):
		me.env = DeploymentEnvInner.bzz_denormalize_multiple(from_dict["env"])
	if from_dict.has("roomsPerProcess"):
		me.roomsPerProcess = from_dict["roomsPerProcess"]
	if from_dict.has("planName"):
		me.planName = from_dict["planName"]
	if from_dict.has("additionalContainerPorts"):
		me.additionalContainerPorts = ContainerPort.bzz_denormalize_multiple(from_dict["additionalContainerPorts"])
	if from_dict.has("defaultContainerPort"):
		me.defaultContainerPort = ContainerPort.bzz_denormalize_single(from_dict["defaultContainerPort"])
	if from_dict.has("transportType"):
		me.transportType = from_dict["transportType"]
	if from_dict.has("containerPort"):
		me.containerPort = from_dict["containerPort"]
	if from_dict.has("createdAt"):
		me.createdAt = from_dict["createdAt"]
	if from_dict.has("createdBy"):
		me.createdBy = from_dict["createdBy"]
	if from_dict.has("requestedMemoryMB"):
		me.requestedMemoryMB = from_dict["requestedMemoryMB"]
	if from_dict.has("requestedCPU"):
		me.requestedCPU = from_dict["requestedCPU"]
	if from_dict.has("deploymentId"):
		me.deploymentId = from_dict["deploymentId"]
	if from_dict.has("buildId"):
		me.buildId = from_dict["buildId"]
	if from_dict.has("appId"):
		me.appId = from_dict["appId"]
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

