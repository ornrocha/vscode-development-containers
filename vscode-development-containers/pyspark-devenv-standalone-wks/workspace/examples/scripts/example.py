from pyspark.sql import SparkSession

spark = SparkSession.builder.getOrCreate()

df = (
    spark.read.option("header", True).option("delimiter", ";").csv("/mnt/data/examples/example.csv")
)

df.show()
