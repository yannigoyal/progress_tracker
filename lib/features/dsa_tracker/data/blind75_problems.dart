class DsaProblem {
  final int id;
  final String name;
  final String difficulty; // 'Easy' | 'Medium' | 'Hard'
  final String topic;

  const DsaProblem({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.topic,
  });

  String get group => switch (topic) {
    'Array' || 'Binary Search' || 'Two Pointers' => 'Array',
    'Bit Manipulation' => 'Bit Manipulation',
    'DP' || 'Greedy' => 'Dynamic Programming',
    'Graph' => 'Graph',
    'Intervals' => 'Intervals',
    'Linked List' => 'Linked List',
    'Matrix' || 'Backtracking' => 'Matrix',
    'Sliding Window' || 'String' || 'Stack' => 'String',
    'Tree' || 'Trie' => 'Tree',
    'Heap' => 'Heap',
    _ => topic,
  };
}

// Placeholder list — 40 problems.  Replace with full Blind 75 when ready.
const blind75Problems = <DsaProblem>[
  // ================= ARRAY =================
  DsaProblem(id: 1, name: 'Two Sum', difficulty: 'Easy', topic: 'Array'),
  DsaProblem(
    id: 121,
    name: 'Best Time to Buy and Sell Stock',
    difficulty: 'Easy',
    topic: 'Array',
  ),
  DsaProblem(
    id: 217,
    name: 'Contains Duplicate',
    difficulty: 'Easy',
    topic: 'Array',
  ),
  DsaProblem(
    id: 238,
    name: 'Product of Array Except Self',
    difficulty: 'Easy',
    topic: 'Array',
  ),
  DsaProblem(
    id: 53,
    name: 'Maximum Subarray',
    difficulty: 'Medium',
    topic: 'Array',
  ),
  DsaProblem(
    id: 152,
    name: 'Maximum Product Subarray',
    difficulty: 'Hard',
    topic: 'Array',
  ),
  DsaProblem(
    id: 153,
    name: 'Find Minimum in Rotated Sorted Array',
    difficulty: 'Easy',
    topic: 'Binary Search',
  ),
  DsaProblem(
    id: 33,
    name: 'Search in Rotated Sorted Array',
    difficulty: 'Medium',
    topic: 'Binary Search',
  ),
  DsaProblem(id: 15, name: '3Sum', difficulty: 'Medium', topic: 'Two Pointers'),
  DsaProblem(
    id: 11,
    name: 'Container With Most Water',
    difficulty: 'Easy',
    topic: 'Two Pointers',
  ),

  // ================= BIT MANIPULATION =================
  DsaProblem(
    id: 371,
    name: 'Sum of Two Integers',
    difficulty: 'Easy',
    topic: 'Bit Manipulation',
  ),
  DsaProblem(
    id: 191,
    name: 'Number of 1 Bits',
    difficulty: 'Easy',
    topic: 'Bit Manipulation',
  ),
  DsaProblem(
    id: 338,
    name: 'Counting Bits',
    difficulty: 'Easy',
    topic: 'Bit Manipulation',
  ),
  DsaProblem(
    id: 268,
    name: 'Missing Number',
    difficulty: 'Easy',
    topic: 'Bit Manipulation',
  ),
  DsaProblem(
    id: 190,
    name: 'Reverse Bits',
    difficulty: 'Easy',
    topic: 'Bit Manipulation',
  ),

  // ================= DYNAMIC PROGRAMMING =================
  DsaProblem(
    id: 70,
    name: 'Climbing Stairs',
    difficulty: 'Medium',
    topic: 'DP',
  ),
  DsaProblem(id: 518, name: 'Coin Change II', difficulty: 'Hard', topic: 'DP'),
  DsaProblem(
    id: 300,
    name: 'Longest Increasing Subsequence',
    difficulty: 'Medium',
    topic: 'DP',
  ),
  DsaProblem(
    id: 1143,
    name: 'Longest Common Subsequence',
    difficulty: 'Hard',
    topic: 'DP',
  ),
  DsaProblem(id: 139, name: 'Word Break', difficulty: 'Medium', topic: 'DP'),
  DsaProblem(
    id: 39,
    name: 'Combination Sum',
    difficulty: 'Medium',
    topic: 'DP',
  ),
  DsaProblem(id: 198, name: 'House Robber', difficulty: 'Medium', topic: 'DP'),
  DsaProblem(
    id: 213,
    name: 'House Robber II',
    difficulty: 'Medium',
    topic: 'DP',
  ),
  DsaProblem(id: 91, name: 'Decode Ways', difficulty: 'Easy', topic: 'DP'),
  DsaProblem(id: 62, name: 'Unique Paths', difficulty: 'Medium', topic: 'DP'),
  DsaProblem(id: 55, name: 'Jump Game', difficulty: 'Easy', topic: 'Greedy'),

  // ================= GRAPH =================
  DsaProblem(
    id: 133,
    name: 'Clone Graph',
    difficulty: 'Medium',
    topic: 'Graph',
  ),
  DsaProblem(
    id: 207,
    name: 'Course Schedule',
    difficulty: 'Hard',
    topic: 'Graph',
  ),
  DsaProblem(
    id: 417,
    name: 'Pacific Atlantic Water Flow',
    difficulty: 'Easy',
    topic: 'Graph',
  ),
  DsaProblem(
    id: 200,
    name: 'Number of Islands',
    difficulty: 'Medium',
    topic: 'Graph',
  ),
  DsaProblem(
    id: 128,
    name: 'Longest Consecutive Sequence',
    difficulty: 'Medium',
    topic: 'Graph',
  ),
  DsaProblem(
    id: 269,
    name: 'Alien Dictionary',
    difficulty: 'Hard',
    topic: 'Graph',
  ),
  DsaProblem(
    id: 261,
    name: 'Graph Valid Tree',
    difficulty: 'Medium',
    topic: 'Graph',
  ),
  DsaProblem(
    id: 323,
    name: 'Number of Connected Components in an Undirected Graph',
    difficulty: 'Medium',
    topic: 'Graph',
  ),

  // ================= INTERVAL =================
  DsaProblem(
    id: 57,
    name: 'Insert Interval',
    difficulty: 'Medium',
    topic: 'Intervals',
  ),
  DsaProblem(
    id: 56,
    name: 'Merge Intervals',
    difficulty: 'Medium',
    topic: 'Intervals',
  ),
  DsaProblem(
    id: 435,
    name: 'Non-overlapping Intervals',
    difficulty: 'Medium',
    topic: 'Intervals',
  ),
  DsaProblem(
    id: 287,
    name: 'Find the Repeating and Missing Number',
    difficulty: 'Hard',
    topic: 'Intervals',
  ),
  DsaProblem(
    id: 252,
    name: 'Meeting Rooms',
    difficulty: 'Easy',
    topic: 'Intervals',
  ),
  DsaProblem(
    id: 253,
    name: 'Meeting Rooms II',
    difficulty: 'Medium',
    topic: 'Intervals',
  ),

  // ================= LINKED LIST =================
  DsaProblem(
    id: 206,
    name: 'Reverse Linked List',
    difficulty: 'Medium',
    topic: 'Linked List',
  ),
  DsaProblem(
    id: 141,
    name: 'Linked List Cycle',
    difficulty: 'Medium',
    topic: 'Linked List',
  ),
  DsaProblem(
    id: 21,
    name: 'Merge Two Sorted Lists',
    difficulty: 'Hard',
    topic: 'Linked List',
  ),
  DsaProblem(
    id: 23,
    name: 'Merge K Sorted Lists',
    difficulty: 'Medium',
    topic: 'Linked List',
  ),
  DsaProblem(
    id: 19,
    name: 'Remove Nth Node From End of List',
    difficulty: 'Medium',
    topic: 'Linked List',
  ),
  DsaProblem(
    id: 143,
    name: 'Reorder List',
    difficulty: 'Easy',
    topic: 'Linked List',
  ),

  // ================= MATRIX =================
  DsaProblem(
    id: 73,
    name: 'Set Matrix Zeroes',
    difficulty: 'Medium',
    topic: 'Matrix',
  ),
  DsaProblem(
    id: 54,
    name: 'Spiral Matrix',
    difficulty: 'Medium',
    topic: 'Matrix',
  ),
  DsaProblem(
    id: 48,
    name: 'Rotate Image',
    difficulty: 'Medium',
    topic: 'Matrix',
  ),
  DsaProblem(
    id: 79,
    name: 'Word Search',
    difficulty: 'Hard',
    topic: 'Backtracking',
  ),

  // ================= STRING =================
  DsaProblem(
    id: 3,
    name: 'Longest Substring Without Repeating Characters',
    difficulty: 'Medium',
    topic: 'Sliding Window',
  ),
  DsaProblem(
    id: 424,
    name: 'Longest Repeating Character Replacement',
    difficulty: 'Hard',
    topic: 'Sliding Window',
  ),
  DsaProblem(
    id: 76,
    name: 'Minimum Window Substring',
    difficulty: 'Hard',
    topic: 'Sliding Window',
  ),
  DsaProblem(
    id: 242,
    name: 'Valid Anagram',
    difficulty: 'Easy',
    topic: 'String',
  ),
  DsaProblem(
    id: 49,
    name: 'Group Anagrams',
    difficulty: 'Medium',
    topic: 'String',
  ),
  DsaProblem(
    id: 20,
    name: 'Valid Parentheses',
    difficulty: 'Easy',
    topic: 'Stack',
  ),
  DsaProblem(
    id: 9,
    name: 'Palindrome Number',
    difficulty: 'Easy',
    topic: 'String',
  ),
  DsaProblem(
    id: 5,
    name: 'Longest Palindromic Substring',
    difficulty: 'Medium',
    topic: 'String',
  ),
  DsaProblem(
    id: 647,
    name: 'Palindromic Substrings',
    difficulty: 'Medium',
    topic: 'String',
  ),
  DsaProblem(
    id: 271,
    name: 'Encode and Decode Strings',
    difficulty: 'Medium',
    topic: 'String',
  ),

  // ================= TREE =================
  DsaProblem(
    id: 104,
    name: 'Maximum Depth of Binary Tree',
    difficulty: 'Medium',
    topic: 'Tree',
  ),
  DsaProblem(id: 100, name: 'Same Tree', difficulty: 'Medium', topic: 'Tree'),
  DsaProblem(
    id: 226,
    name: 'Invert Binary Tree',
    difficulty: 'Medium',
    topic: 'Tree',
  ),
  DsaProblem(
    id: 124,
    name: 'Binary Tree Maximum Path Sum',
    difficulty: 'Medium',
    topic: 'Tree',
  ),
  DsaProblem(
    id: 102,
    name: 'Binary Tree Level Order Traversal',
    difficulty: 'Easy',
    topic: 'Tree',
  ),
  DsaProblem(
    id: 297,
    name: 'Serialize and Deserialize Binary Tree',
    difficulty: 'Hard',
    topic: 'Tree',
  ),
  DsaProblem(
    id: 572,
    name: 'Subtree of Another Tree',
    difficulty: 'Easy',
    topic: 'Tree',
  ),
  DsaProblem(
    id: 106,
    name: 'Construct Binary Tree from Postorder and Inorder Traversal',
    difficulty: 'Hard',
    topic: 'Tree',
  ),
  DsaProblem(
    id: 98,
    name: 'Validate Binary Search Tree',
    difficulty: 'Medium',
    topic: 'Tree',
  ),
  DsaProblem(
    id: 230,
    name: 'Kth Smallest Element in a BST',
    difficulty: 'Medium',
    topic: 'Tree',
  ),
  DsaProblem(
    id: 235,
    name: 'Lowest Common Ancestor of a BST',
    difficulty: 'Medium',
    topic: 'Tree',
  ),
  DsaProblem(
    id: 208,
    name: 'Implement Trie (Prefix Tree)',
    difficulty: 'Hard',
    topic: 'Trie',
  ),
  DsaProblem(
    id: 212,
    name: 'Word Search II (Trie Advanced)',
    difficulty: 'Hard',
    topic: 'Trie',
  ),

  // ================= HEAP =================
  DsaProblem(
    id: 347,
    name: 'Top K Frequent Elements',
    difficulty: 'Medium',
    topic: 'Heap',
  ),
  DsaProblem(
    id: 295,
    name: 'Find Median from Data Stream',
    difficulty: 'Hard',
    topic: 'Heap',
  ),
];
