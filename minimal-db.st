#
# Minimal OpenEdge Database Structure File - Type II Storage Areas
# Simple configuration for development/testing
#

# Begin database structure
b .

#
# Schema Area - Table and index definitions
# Area 6: 64 blocks/cluster, 1 cluster
#
d "Schema Area":6,64;1 .

#
# Data Area - Table data storage
# Area 7: 256 blocks/cluster, 8 clusters
#
d "Data Area":7,256;8 .

#
# Index Area - Index storage
# Area 8: 32 blocks/cluster, 8 clusters
#
e "Index Area":8,32;8 .

# End of structure file
