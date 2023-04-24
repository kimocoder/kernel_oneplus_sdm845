#!/usr/bin/python

"""
Copyright 2008 (c) Frederic Weisbecker <fweisbec@gmail.com>
Licensed under the terms of the GNU GPL License version 2

This script parses a trace provided by the function tracer in
kernel/trace/trace_functions.c
The resulted trace is processed into a tree to produce a more human
view of the call stack by drawing textual but hierarchical tree of
calls. Only the functions's names and the the call time are provided.

Usage:
	Be sure that you have CONFIG_FUNCTION_TRACER
	# mount -t debugfs nodev /sys/kernel/debug
	# echo function > /sys/kernel/debug/tracing/current_tracer
	$ cat /sys/kernel/debug/tracing/trace_pipe > ~/raw_trace_func
	Wait some times but not too much, the script is a bit slow.
	Break the pipe (Ctrl + Z)
	$ scripts/draw_functrace.py < raw_trace_func > draw_functrace
	Then you have your drawn trace in draw_functrace
"""


import sys, re

class CallTree:
	""" This class provides a tree representation of the functions
		call stack. If a function has no parent in the kernel (interrupt,
		syscall, kernel thread...) then it is attached to a virtual parent
		called ROOT.
	"""
	ROOT = None

	def __init__(self, func, time = None, parent = None):
		self._func = func
		self._time = time
		self._parent = CallTree.ROOT if parent is None else parent
		self._children = []

	def calls(self, func, calltime):
		""" If a function calls another one, call this method to insert it
			into the tree at the appropriate place.
			@return: A reference to the newly created child node.
		"""
		child = CallTree(func, calltime, self)
		self._children.append(child)
		return child

	def getParent(self, func):
		""" Retrieve the last parent of the current node that
			has the name given by func. If this function is not
			on a parent, then create it as new child of root
			@return: A reference to the parent.
		"""
		tree = self
		while tree != CallTree.ROOT and tree._func != func:
			tree = tree._parent
		return CallTree.ROOT.calls(func, None) if tree == CallTree.ROOT else tree

	def __repr__(self):
		return self.__toString("", True)

	def __toString(self, branch, lastChild):
		i = 0
		s = (
			"%s----%s (%s)\n" % (branch, self._func, self._time)
			if self._time is not None
			else "%s----%s\n" % (branch, self._func)
		)
		if lastChild:
			branch = f"{branch[:-1]} "
		while i < len(self._children):
			if i != len(self._children) - 1:
				s += f'{self._children[i].__toString(f"{branch}    |", False)}'
			else:
				s += f'{self._children[i].__toString(f"{branch}    |", True)}'
			i += 1
		return s

class BrokenLineException(Exception):
	"""If the last line is not complete because of the pipe breakage,
	   we want to stop the processing and ignore this line.
	"""
	pass

class CommentLineException(Exception):
	""" If the line is a comment (as in the beginning of the trace file),
	    just ignore it.
	"""
	pass


def parseLine(line):
	line = line.strip()
	if line.startswith("#"):
		raise CommentLineException
	m = re.match("[^]]+?\\] +([0-9.]+): (\\w+) <-(\\w+)", line)
	if m is None:
		raise BrokenLineException
	return m[1], m[2], m[3]


def main():
	CallTree.ROOT = CallTree("Root (Nowhere)", None, None)
	tree = CallTree.ROOT

	for line in sys.stdin:
		try:
			calltime, callee, caller = parseLine(line)
		except BrokenLineException:
			break
		except CommentLineException:
			continue
		tree = tree.getParent(caller)
		tree = tree.calls(callee, calltime)

	print CallTree.ROOT

if __name__ == "__main__":
	main()
