import argparse
import boundingbox as bb
import database as db
import data_loader as dl
import kdtree as kd
import matplotlib.pyplot as plt
import matplotlib
import plotter as pl
import matplotlib.animation as animation
import matplotlib.patches as mpatches
import matplotlib.colors as mcolors
import numpy as np

# lab
import quadtree as qt
from quadtree import QuadTree
from matplotlib.collections import PatchCollection


if __name__ == '__main__':
	
	parser = argparse.ArgumentParser(description = 'KDTree plotting program.')

	parser.add_argument('--filename', help='file containing spatial information.',type=str)
	parser.add_argument('--max-depth', help='the maximum depth of the KDTree.',type=int,default=3)
	parser.add_argument('--max-elements', help='the maximum of elements in a KDTree leave.',type=int, default=1000)
	parser.add_argument('--bbox-depth', help='display the bounding-boxes at specific depth.',type=int,default=2)
	parser.add_argument('--plot', help='choose what to plot (kdtree-bb,storage)',type=str,default="kdtree-bb")
	parser.add_argument('--range-query', help='bbox range query, "1 2; 3 4"',type=str)	
	parser.add_argument('--closest', help='closest point query, "1 2"',type=str)
	parser.add_argument('--quadtree', help='add quadtree indexing depth, 2',type=int)
	parser.add_argument('--quadlevel', help='select all points up to this level, 2',type=int)
	parser.add_argument('--quadshow', help='display the quadtree',type=bool,default=False)
	

	args = parser.parse_args()

	
	# Construct database	
	fields = ["x","y"]
	if args.quadtree:
		fields.append("quad")
	dtb =  db.Database(fields)
	field_idx = dtb.fields()
	
	# Load the data
	data_loader = dl.DataLoader()
	data_loader.load(args,dtb)

	# Create KDTree
	tree = kd.KDTree(dtb, {'max-depth' : args.max_depth, 'max-elements' : args.max_elements})

	plotter = pl.Plotter(tree,dtb,args)


	# Testing: Implementing the QuadTree
	if args.quadtree:
		quadtree = qt.QuadTree(tree.bounding_box(), args.quadtree)
		if args.quadshow:
			plotter.add_quadtree(quadtree)

	# Testing: Implementing the KDTree
	if args.closest:
		# This is for testing, to check if your closest query is correclty implemented

		# Step 1 query and fetch		
		closest_query = np.fromstring(args.closest,dtype=float, sep=' ')
		query = dtb.query(tree.closest(closest_query))

		# Step 2 compare found geometry with closest_point	
		geometries= [[x[field_idx["x"]],x[field_idx["y"]] ] for x in query]
		distances = [np.linalg.norm(closest_query - geom) for geom in geometries]
		ordered = np.argsort(distances)
		
		# Step 3 plot search and result point
		plotter.add_closest_query(closest_query,geometries[ordered[0]])

	# Using the QuadTree depth to subsample the KDTree
	if args.quadtree:  # Check if quadtree parameter is supplied
		if args.quadlevel:  # Check if quadlevel parameter is supplied
			# Set the quad field for all the records in the database to max quad-level
			for rec in dtb.db:
				dtb.update_field(rec, "quad", args.quadlevel)

		"""
        Iterate the Quad tree from maximum depth to minimum.
        For each BoundingBox in the Quad perform the following,
            centroid -> calculate the centroid of the BoundingBox
            tree.closes -> invoke KDtree to traverse the tree to get the closest datapoint for            the given centroid (section 3).
            query -> Get the X and Y coordinates of the closest point from the database
                     (databse: stores a structure like, 'Key, X, Y').
            geometrics -> Get the X and Y coordinates from all the datpoint fetched from the           closest leafnode.
            distances -> Compute the distances between the centroid and the datapoints.
            closest_point -> Sort aesc the distances and fetch the datapoint closest to centroid.
            dtb.updatefield(...) -> Update the quad field of the record to the current level.
        """
		for level in reversed(range(quadtree.depth - 1)):
			for bb in quadtree.quads[level]:
				centroid = bb.centroid()
				query = dtb.query(tree.closest(centroid))
				geometries = [[x[1], x[2]] for x in query]
				distances = [np.linalg.norm(np.asarray(centroid) - geom) for geom in geometries]
				ordered_dist = np.argsort(distances)
				closest_point = ordered_dist[0]
				dtb.update_field(query[closest_point][0], "quad", level)

	plotter.plot()




