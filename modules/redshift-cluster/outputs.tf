output "sg12_aws_redshift_cluster_arn" {
  value= aws_redshift_cluster.data_warehouse_cluster.arn
}

output "sg12_aws_redshift_cluster_endpoint" {
  value= aws_redshift_cluster.data_warehouse_cluster.endpoint
}

output "sg12_aws_redshift_cluster_database_name" {
  value= aws_redshift_cluster.data_warehouse_cluster.database_name
}