{% from "elasticsearch/map.jinja" import host_lookup as config with context %}

# Create LVM structure
{% if config.elasticsearch.mounts.create_lvm == 'true' %}
{{ config.elasticsearch.mounts.lvm_pv_name }}:
  lvm.pv_present
{{ config.elasticsearch.mounts.lvm_vg_name }}:
  lvm.vg_present:
    - devices: {{ config.elasticsearch.mounts.lvm_pv_name }}
{{ config.elasticsearch.mounts.lvm_data_lv_name }}:
  lvm.lv_present:
    - vgname: {{ config.elasticsearch.mounts.lvm_vg_name }}
    - size: {{ config.elasticsearch.mounts.lvm_data_lv_size }}
# If we need an archive dir and chose to create LVM structure - create an LV for it
  {% if config.elasticsearch.mounts.use_archive_dir == 'true' %}
{{ config.elasticsearch.mounts.lvm_archive_lv_name }}:
  lvm.lv_present:
    - vgname: {{ config.elasticsearch.mounts.lvm_vg_name }}
    - size: {{ config.elasticsearch.mounts.lvm_archive_lv_size }}
  {% endif %}
{% endif %}

# If we need an archive dir - create the FS and mountpoint for it
{% if config.elasticsearch.mounts.use_archive_dir == 'true' %}
format-{{ config.elasticsearch.mounts.archive_mount_device }}:
# The following block is temporary until issue #44559 is resolved.
# If it is already resolved - feel free to uncomment blockdev.formatted and comment out cmd.run
  cmd.run:
    - name: '/sbin/mkfs.{{ config.elasticsearch.mounts.archive_mount_fstype }} -K {{ config.elasticsearch.mounts.archive_mount_device }}'
    - unless: '/usr/bin/file -Ls {{ config.elasticsearch.mounts.archive_mount_device }} | grep Linux'
#  blockdev.formatted:
#    - name: {{ config.elasticsearch.mounts.archive_mount_device }}
#    - fs_type: {{ config.elasticsearch.mounts.archive_mount_fstype }}
mount-{{ config.elasticsearch.mounts.archive_dir_name }}:
  mount.mounted:
    - name: {{ config.elasticsearch.mounts.archive_dir_name }}
    - fstype: {{ config.elasticsearch.mounts.archive_mount_fstype }}
    - device: {{ config.elasticsearch.mounts.archive_mount_device }}
    - mkmnt: True
    - require:
      - format-{{ config.elasticsearch.mounts.archive_mount_device }}  
{{ config.elasticsearch.mounts.archive_dir_name }}:
  file.directory:
    - user: elasticsearch
    - group: elasticsearch
    - mode: '0755'
    - makedirs: True
    - require:
      - mount-{{ config.elasticsearch.mounts.archive_dir_name }}
{% endif %}

# Use a mount device for the data mount point
# and create entry in fstab
format-{{ config.elasticsearch.mounts.data_mount_device }}:
# The following block is temporary until issue #44559 is resolved.
# If it is already resolved - feel free to uncomment blockdev.formatted and comment out cmd.run
  cmd.run:
    - name: '/sbin/mkfs.{{ config.elasticsearch.mounts.data_mount_fstype }} -K {{ config.elasticsearch.mounts.data_mount_device }}'
    - unless: '/usr/bin/file -Ls {{ config.elasticsearch.mounts.data_mount_device }} | grep Linux'
#  blockdev.formatted:
#    - name: {{ config.elasticsearch.mounts.data_mount_device }}
#    - fs_type: {{ config.elasticsearch.mounts.data_mount_fstype }}
mount-{{ config.elasticsearch.mounts.data_dir_name }}:
  mount.mounted:
    - name: {{ config.elasticsearch.mounts.data_dir_name }}
    - fstype: {{ config.elasticsearch.mounts.data_mount_fstype }}
    - device: {{ config.elasticsearch.mounts.data_mount_device }}
    - mkmnt: True 
    - require:
      - format-{{ config.elasticsearch.mounts.data_mount_device }}
{{ config.elasticsearch.mounts.data_dir_name }}:
  file.directory:
    - user: elasticsearch
    - group: elasticsearch
    - mode: '0755'
    - makedirs: True
    - require:
      - mount-{{ config.elasticsearch.mounts.data_dir_name }}
