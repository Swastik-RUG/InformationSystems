import boundingbox as bb
import math


class QuadTree:
    """
    The QuadTree class is a tree data structure in which each internal
    non leave node has exactly four children.

    the internal data structre `self.quads = {}` is a dictionary where its
    keys represent depth (starting from 0) and has a list of BoundingBoxes representing
    the partions/space. The total area of at each level should remain equal to the initial
    bounding box.

    self.quads =
    {
        0: [1    x BoundingBox ]
        1: [4    x BoundingBox ]
        ..
        n: [4**n x BoundingBox ]
    }

    Generation of the QuadTree is slow, using it to reduce your dataset it fast.

    """

    def __init__(self, bbox, depth):
        self.quads = {}
        self.depth = depth
        for x in range(depth):
            self.quads[x] = []
        self.quads[0] = [bbox]
        self.recurse(bbox, 1)

    def recurse(self, _bbox, depth):

        # Stop the recursion when the below condition is satisfied
        if depth >= self.depth:
            return
        """
        centroid - Calculate the centroid of the BoundingBox
        minx -  minimum x of the bounding box
        maxx -  maximum x of the bounding box
        miny -  minimum y of the bounding box
        maxy -  maximum y of the bounding box
        nw, ne, sw, se - The points that form the four BoundingBoxes
        """
        centroid = _bbox.centroid()
        minx = _bbox.data[0, 0]
        maxx = _bbox.data[0, 1]
        miny = _bbox.data[1, 0]
        maxy = _bbox.data[1, 1]
        nw = bb.BoundingBox(minx, centroid[0], miny, centroid[1])
        ne = bb.BoundingBox(centroid[0], maxx, miny, centroid[1])
        sw = bb.BoundingBox(minx, centroid[0], centroid[1], maxy)
        se = bb.BoundingBox(centroid[0], maxx, centroid[1], maxy)
        # The bounding boxes created are added to the quads map, with the parameter depth used as key
        self.quads[depth] += [nw]
        self.quads[depth] += [ne]
        self.quads[depth] += [sw]
        self.quads[depth] += [se]

        depth = depth + 1
        # each of the resulting bounding boxes are sent as parameters to the recursion function.
        self.recurse(nw, depth)
        self.recurse(ne, depth)
        self.recurse(sw, depth)
        self.recurse(se, depth)

    @staticmethod
    def at_least(size):

        """
        Returns the amount of BoundingBoxes when the user
        request `at least` an amount of bboxes. The returned
        value is >= than size.

        :param size: minimum requested size

        :Example:
#		>>> print(QuadTree.at_least(900))
#		>>> 1024
        """
        return 4 ** int(math.ceil(math.log(size, 4)))


@staticmethod
def at_most(size):
    """
    Returns the amount of BoundingBoxes when the user
    request `at most` an amount of bboxes. The returned
    value is <= than size.

    :param size: maximum requested size

    :Example:
#		>>> print(QuadTree.at_most(900))
#		>>> 256
    """
    return 4 ** int(math.floor(math.log(size, 4)))


@staticmethod
def level(size):
    return int(math.ceil(math.log(size, 4)))


def quadrants(self):
    return self.quads


if __name__ == '__main__':

    bbox = bb.BoundingBox(0, 10, 0, 10)

    qt = QuadTree(bbox, 3)
    for k, v in qt.quads.items():
        print(k, len(v))
        for x in v:
            print(x.data)
