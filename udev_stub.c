// Complete libudev stub to prevent segfault under Rosetta x86_64
// emulation in Docker on Apple Silicon.
// Vivado's license manager dlopen()s libudev and calls
// udev_enumerate_scan_devices, which crashes under emulation.

#include <stddef.h>
#include <stdlib.h>
#include <string.h>

// Opaque types - just need to be non-NULL pointers
struct udev;
struct udev_enumerate;
struct udev_list_entry;
struct udev_device;

struct udev *udev_new(void) {
    return (struct udev *)calloc(1, 64);
}

struct udev *udev_ref(struct udev *udev) {
    return udev;
}

struct udev *udev_unref(struct udev *udev) {
    free(udev);
    return NULL;
}

struct udev_enumerate *udev_enumerate_new(struct udev *udev) {
    return (struct udev_enumerate *)calloc(1, 64);
}

struct udev_enumerate *udev_enumerate_ref(struct udev_enumerate *e) {
    return e;
}

struct udev_enumerate *udev_enumerate_unref(struct udev_enumerate *e) {
    free(e);
    return NULL;
}

int udev_enumerate_add_match_subsystem(struct udev_enumerate *e, const char *subsystem) {
    return 0;
}

int udev_enumerate_add_match_property(struct udev_enumerate *e, const char *property, const char *value) {
    return 0;
}

int udev_enumerate_add_match_sysattr(struct udev_enumerate *e, const char *sysattr, const char *value) {
    return 0;
}

int udev_enumerate_add_match_tag(struct udev_enumerate *e, const char *tag) {
    return 0;
}

int udev_enumerate_scan_devices(struct udev_enumerate *e) {
    return 0;
}

int udev_enumerate_scan_subsystems(struct udev_enumerate *e) {
    return 0;
}

struct udev_list_entry *udev_enumerate_get_list_entry(struct udev_enumerate *e) {
    return NULL;  // empty list
}

struct udev_list_entry *udev_list_entry_get_next(struct udev_list_entry *e) {
    return NULL;
}

const char *udev_list_entry_get_name(struct udev_list_entry *e) {
    return NULL;
}

const char *udev_list_entry_get_value(struct udev_list_entry *e) {
    return NULL;
}

struct udev_device *udev_device_new_from_syspath(struct udev *udev, const char *syspath) {
    return NULL;
}

struct udev_device *udev_device_new_from_devnum(struct udev *udev, char type, unsigned long long devnum) {
    return NULL;
}

struct udev_device *udev_device_new_from_subsystem_sysname(struct udev *udev, const char *subsystem, const char *sysname) {
    return NULL;
}

struct udev_device *udev_device_ref(struct udev_device *d) {
    return d;
}

struct udev_device *udev_device_unref(struct udev_device *d) {
    return NULL;
}

const char *udev_device_get_devpath(struct udev_device *d) { return NULL; }
const char *udev_device_get_subsystem(struct udev_device *d) { return NULL; }
const char *udev_device_get_devtype(struct udev_device *d) { return NULL; }
const char *udev_device_get_syspath(struct udev_device *d) { return NULL; }
const char *udev_device_get_sysname(struct udev_device *d) { return NULL; }
const char *udev_device_get_sysnum(struct udev_device *d) { return NULL; }
const char *udev_device_get_devnode(struct udev_device *d) { return NULL; }
const char *udev_device_get_driver(struct udev_device *d) { return NULL; }
const char *udev_device_get_action(struct udev_device *d) { return NULL; }
const char *udev_device_get_property_value(struct udev_device *d, const char *key) { return NULL; }
const char *udev_device_get_sysattr_value(struct udev_device *d, const char *sysattr) { return NULL; }
struct udev_device *udev_device_get_parent(struct udev_device *d) { return NULL; }
struct udev_device *udev_device_get_parent_with_subsystem_devtype(struct udev_device *d, const char *subsystem, const char *devtype) { return NULL; }
struct udev_list_entry *udev_device_get_properties_list_entry(struct udev_device *d) { return NULL; }
struct udev_list_entry *udev_device_get_sysattr_list_entry(struct udev_device *d) { return NULL; }
