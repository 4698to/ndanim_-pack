(
	for i = getNumNamedselsets() to 1 by -1 do
	(
		--set_sets = getNamedselsetItemcount i
		a = #()
		NamedSelectionSetManager.GetNamedSelSetList &a i 
		b = makeUniqueArray a
		if b.count == 1 and b[1] == undefined do 
		(
			--print(i)
			--format "i % -> % \r\n " i (NamedSelectionSetManager.GetNamedSelSetName i)
			NamedSelectionSetManager.RemoveNamedSelSetByIndex i 
		)
	)
)