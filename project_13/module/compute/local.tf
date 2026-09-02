locals {
  ebs_flat = merge([
    for inst_key, inst in var.instances : {
      for vol_key, vol in inst.ebs_volumes :
      "${inst_key}.${vol_key}" => merge(vol, { instance_key = inst_key })
    }
  ]...)
  subnet_ids = {
    public  = var.public_subnet_ids
    private = var.private_subnet_ids
  }
}