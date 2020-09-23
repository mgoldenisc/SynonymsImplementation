Class Test.Synonyms Extends %iFind.Synonym [ Language = objectscript ]
{

Query GetMatchesSQL(input As %String) As %Query(ROWSPEC = "Synonym:%String") [ SqlName = GetMatches ]
{
}

ClassMethod GetMatchesSQLExecute(ByRef qHandle As %Binary, input As %String) As %Status
{
	set tSC = ..GetMatch(input, .tMatches)
	quit:$$$ISERR(tSC) tSC
	kill qHandle
	set tWord = ""
	for {
		set tWord = $order(tMatches(tWord))
		quit:tWord=""
		set qHandle($i(qHandle)) = tWord
	}
	set qHandle=0
	quit $$$OK
}

ClassMethod GetMatchesSQLClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = GetMatchesSQLExecute ]
{
	kill qHandle
	Quit $$$OK
}

ClassMethod GetMatchesSQLFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = GetMatchesSQLExecute ]
{
	set qHandle = $order(qHandle(qHandle),1,tWord)
	if qHandle="" {
	set AtEnd=1, Row=""
	} else {
	set AtEnd=0, Row=$lb(tWord)
	}
	quit $$$OK
}

ClassMethod GetMatch(Source As %String, ByRef Matches, ByRef IndexParam, NumSimilar As %Integer = 5) As %Status
{
		
	kill Matches
	set ik = ##class(%SYS.Python).Import("synonymdetection.iksimilarity")
	set syntool = ik.IKWord2VecTools("1bw_tokenized_150d_W2V")
		
	set wordlist = syntool."most_similar"(Source, NumSimilar)
		
	for i=0:1:NumSimilar-1
	{
		set Matches(wordlist."__getitem__"(i)) = ""
	}
		
		
	quit $$$OK
}

}
