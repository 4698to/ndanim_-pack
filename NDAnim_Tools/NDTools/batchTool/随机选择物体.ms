( 
On Execute do (
rollout randomselect "随机选择-myl" width:162 height:89
(
	spinner spn_per "百分比" pos:[14,14] width:137 height:16 range:[0,100,50]
	button btn_select "随机选择" pos:[7,40] width:143 height:24



	on btn_select pressed do
	(
	aa=getcurrentselection()
	cc=aa.count
	thawselection()
	percent=(spn_per.value/100)
	bb=#()
	while (bb.count*1.0/cc)<percent do (
	kk=random 1 aa.count
	print kk
	append bb aa[kk]
	deleteitem aa kk
	)
	select bb
		)
)
createdialog randomselect
)
 ) 