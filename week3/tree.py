from collections import deque

class CategoryTree:
    def __init__(self):
        self.root = None
        self.node_table = {}
    
    def _set_root(self):
        try:
            first_cat_id = next(iter(self.node_table))
        except StopIteration as e:
            self.root = None
        else:
            node = self.node_table[first_cat_id]
            while node.parent is not None:
                node = node.parent
            self.root = node
    
    def _get_nodes_by_level(self) -> list[list]:
        level_nodes_list = []
        queue = deque()
        queue.append(self.root)

        while queue:
            num_nodes_at_level = len(queue)
            level_nodes = []
            for _ in range(num_nodes_at_level):
                node = queue.popleft()
                level_nodes.append(node)
                for child_node in node.children:
                    queue.append(child_node)
            level_nodes_list.append(level_nodes)
        
        return level_nodes_list
        
    def build_tree(self, child_parent_map: dict):
        for child_id, parent_id in child_parent_map.items():
            child_node = self.node_table.setdefault(child_id, CategoryNode(child_id))
            parent_node = self.node_table.setdefault(parent_id, CategoryNode(parent_id))
            child_node.parent = parent_node
            parent_node.children.append(child_node)
        
        self._set_root()
    
    def populate_queries(self, category_queries_map: dict):
        for cat_id, queries in category_queries_map.items():
            self.node_table[cat_id].queries = queries
    
    def get_rolled_up_categories(self, query_count_threshold: int) -> dict:
        rolled_up_nodes = []
        level_nodes_list = self._get_nodes_by_level()
        for level in reversed(range(len(level_nodes_list))):
            for node in level_nodes_list[level]:
                if not node.queries:
                    continue
                elif len(node.queries) >= query_count_threshold:
                    rolled_up_nodes.append(node)
                else:
                    node.roll_up()
        
        category_queries_map = {}
        for node in rolled_up_nodes:
            category_queries_map |= node.to_dict()
        return category_queries_map
        
    
class CategoryNode:
    def __init__(self, cat_id: str):
        self.cat_id = cat_id
        self.parent = None
        self.children = []
        self.queries = []
    
    def roll_up(self):
        assert self.parent is not None
        self.parent.queries += self.queries
        self.queries = []
    
    def to_dict(self):
        return {self.cat_id: self.queries}
