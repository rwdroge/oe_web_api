# Creating an OpenEdge Database with Type II Storage Areas

## Overview

To create an OpenEdge database with Type II storage areas and a proper schema area, you'll need to create a structure file (`.st`) and use the `prodb` and `prostrct` utilities.

## Structure File Format

A structure file defines the storage areas for your database. Type II areas use variable-length extents with clusters for better space management and performance.

### Basic Format

```
b .
d "Area Name":area#,blocks-per-cluster;clusters-per-area .
d "Area Name":area#,blocks-per-cluster;clusters-per-area .
e "Last Area":area#,blocks-per-cluster;clusters-per-area .
```

**Components:**
- `b .` - Begin database structure
- `d` - Define an area (Type II)
- `e` - End with the last area
- **area#** - Unique area number (e.g., 6, 7, 8)
- **blocks-per-cluster** - Number of database blocks per cluster
- **clusters-per-area** - Number of clusters in the area

## Recommended Production Structure File

See attached `production-db.st` file for a complete example with:
- Schema Area (for metadata)
- Data Area (for table data)
- Index Area (for indexes)
- LOB Area (for large objects)
- Audit areas (for audit data)
- Change tracking areas
- Encryption policy area

## Steps to Create Database

### 1. Create the structure file

Save the attached `production-db.st` file or create your own minimal version:

```
b .
d "Schema Area":6,64;1 .
d "Data Area":7,256;8 .
e "Index Area":8,32;8 .
```

### 2. Create the database

```bash
# Create empty database
prodb mydb empty

# Or create with default structure
prodb mydb create
```

### 3. Apply the structure file

```bash
# Add storage areas from structure file
prostrct add mydb mydb.st
```

### 4. Verify the structure

```bash
# List database structure
prostrct list mydb

# Display detailed information
proutil mydb -C describe
```

## Best Practices

### Schema Area
- **Size:** Keep small (64 blocks/cluster, 1 cluster)
- **Purpose:** Stores table and index definitions
- **Area #:** Typically 6

### Data Areas
- **Size:** Larger blocks (256) for better I/O performance
- **Purpose:** Store table data
- **Area #:** Start at 7, use 10, 20, 30 for additional areas

### Index Areas
- **Size:** Smaller blocks (32) for efficient index storage
- **Purpose:** Store index data
- **Area #:** Start at 8, use gaps for future expansion

### General Guidelines
1. Use **gaps in area numbers** (6, 7, 8, 10, 20) to allow future insertions
2. Separate **high-volume tables** into dedicated areas
3. Keep **Schema Area small** - it rarely grows
4. Use **Type II areas** for production databases (better than Type I)
5. Plan for **growth** - clusters allow dynamic expansion

## Common Area Numbers

| Area Number | Typical Use |
|-------------|-------------|
| 6 | Schema Area |
| 7 | Primary Data Area |
| 8 | Primary Index Area |
| 9 | LOB Area |
| 10-19 | Additional Data Areas |
| 20-29 | Additional Index Areas |
| 30+ | Special purpose areas |

## Example: Creating a Multi-Area Database

```bash
# 1. Create structure file (myapp.st)
cat > myapp.st << 'EOF'
b .
d "Schema Area":6,64;1 .
d "Data Area":7,256;8 .
d "Index Area":8,32;8 .
d "LOB Area":9,32;8 .
d "Customer Data":10,256;8 .
e "Customer Index":11,32;8 .
EOF

# 2. Create database
prodb myapp empty

# 3. Apply structure
prostrct add myapp myapp.st

# 4. Verify
prostrct list myapp
```

## Troubleshooting

**Issue:** "Area already exists"
- **Solution:** Use `prostrct remove` to remove areas before re-adding

**Issue:** "Invalid area number"
- **Solution:** Ensure area numbers are unique and in valid range (6-32767)

**Issue:** "Database already has extents"
- **Solution:** Create database with `empty` option, not `create`

## Additional Resources

- See attached `production-db.st` for a complete production-ready example
- Use `promon` to monitor area usage and performance
- Consider using multiple data areas for tables with different access patterns

## Attached Files

1. `production-db.st` - Complete production structure file example
2. `minimal-db.st` - Minimal structure file for testing

---

*This structure file format works with OpenEdge 11.x and 12.x. Type II storage areas are recommended for all production databases.*
