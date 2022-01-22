# Multisegment AVI import
function AppendSegment(
\   clip sample,
\ string base,
\    int first_val,
\    int last_val,
\ string format,
\ string resizer
\){
	filename = base + string(first_val, format) + ".avi"
	result = AviSource(filename)
	result = result.Eval(resizer + """Resize(sample.width, sample.height)""")
	
	for (i = first_val + 1, last_val) {
		filename = base + string(i, format) + ".avi"
		next_clip = AviSource(filename)
		next_clip = next_clip.Eval(resizer + """Resize(sample.width, sample.height)""")
		result = result + next_clip
	}
	
	return result
}