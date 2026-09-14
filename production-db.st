#
# OpenEdge Database Structure File - Type II Storage Areas
# Production-ready configuration with comprehensive area separation
#
# This structure file defines Type II storage areas for optimal
# database performance and management.
#
# Format: d "Area Name":area#,blocks-per-cluster;clusters-per-area .
#

# Begin database structure
b .

#
# Schema Area - Stores table and index definitions
# Keep small as it rarely grows
# Area 6: 64 blocks/cluster, 1 cluster
#
d "Schema Area":6,64;1 .

#
# Primary Data Area - Main table data storage
# Larger blocks for better I/O performance
# Area 7: 256 blocks/cluster, 8 clusters
#
d "Data Area":7,256;8 .

#
# Primary Index Area - Main index storage
# Smaller blocks for efficient index operations
# Area 8: 32 blocks/cluster, 8 clusters
#
d "Index Area":8,32;8 .

#
# LOB Area - Large Object storage (CLOB/BLOB)
# For storing large text or binary data
# Area 9: 32 blocks/cluster, 8 clusters
#
d "LOB Area":9,32;8 .

#
# Audit Data Area - Audit trail data
# Stores audit policy data
# Area 40: 256 blocks/cluster, 8 clusters
#
d "Audit Data Area":40,256;8 .

#
# Audit Index Area - Audit trail indexes
# Indexes for audit data
# Area 50: 32 blocks/cluster, 8 clusters
#
d "Audit Index Area":50,32;8 .

#
# Change Data Area - CDC (Change Data Capture) data
# Stores change tracking information
# Area 60: 256 blocks/cluster, 8 clusters
#
d "Change Data Area":60,256;8 .

#
# Change Index Area - CDC indexes
# Indexes for change tracking data
# Area 70: 32 blocks/cluster, 8 clusters
#
d "Change Index Area":70,32;8 .

#
# Encryption Policy Area - Encryption metadata
# Stores encryption policy information
# Area 80: 32 blocks/cluster, 8 clusters
# Note: Use 'e' for the last area definition
#
e "Encryption Policy Area":80,32;8 .

#
# Optional: Add custom areas for high-volume tables
# Uncomment and modify as needed:
#
# d "Customer Data":10,256;8 .
# d "Customer Index":11,32;8 .
# d "Order Data":20,256;8 .
# d "Order Index":21,32;8 .
# d "Transaction Data":30,512;16 .
# e "Transaction Index":31,64;16 .
#

# End of structure file
