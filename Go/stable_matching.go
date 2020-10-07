//Manlin Guo 6602848
package main

import (
	"encoding/csv"
	"fmt"
	"os"
	"strconv"
	"sync"
)

var resultMap map[string]string = make(map[string]string)
var employerMap map[string][]string
var studentMap map[string][]string
var matching chan [2]string = make(chan [2]string)
var size int
var mux sync.Mutex

func readFile(fileName string) map[string][]string {
	m := make(map[string][]string)
	file, err1 := os.Open(fileName)
	if err1 != nil {
		fmt.Println("can't open file")
		panic(err1)
	}
	reader := csv.NewReader(file)
	data, err2 := reader.ReadAll()
	if err2 != nil {
		fmt.Println("can't read file")
		panic(err2)
	}
	for _, line := range data {
		key := line[0]
		val := line[1:]
		m[key] = val
	}
	return m
}
func writeFile(resultMap map[string]string, fileName string) {
	file, err1 := os.Create(fileName)
	if err1 != nil {
		fmt.Println("Can't create file")
		panic(err1)
	}
	writer := csv.NewWriter(file)
	var data [][]string
	for e, s := range resultMap {
		var line []string
		line = append(line, e)
		line = append(line, s)
		data = append(data, line)
	}
	err2 := writer.WriteAll(data)
	if err2 != nil {
		fmt.Println("Can't write file")
		panic(err2)
	}
}
func offer(name string) {
	mux.Lock()
	ePreferences := employerMap[name]
	mux.Unlock()
	student := ePreferences[0]
	var pair [2]string
	pair[0] = name
	pair[1] = student
	mux.Lock()
	employerMap[name] = employerMap[name][1:]
	mux.Unlock()
	matching <- pair

}
func evaluate() {
	for len(resultMap) < size {
		pair := <-matching
		e := pair[0]
		s := pair[1]

		studnetIsMatched := false
		var eCurrent string
		for matchedEmployer, matchedStudent := range resultMap {
			if matchedStudent == s {
				studnetIsMatched = true
				eCurrent = matchedEmployer
			}
		}
		if !studnetIsMatched {
			resultMap[e] = s
		} else {
			sPreferences := studentMap[s]
			var eCurrentIndex int
			var eIndex int
			for index, employer := range sPreferences {
				if employer == eCurrent {
					eCurrentIndex = index
				}
				if employer == e {
					eIndex = index
				}
			}
			if eIndex < eCurrentIndex {
				delete(resultMap, eCurrent)
				resultMap[e] = s
				go offer(eCurrent)
			} else {
				go offer(e)
			}
		}
	}
}

func main() {
	eFilename := os.Args[1]
	sFilename := os.Args[2]
	employerMap = readFile(eFilename)
	studentMap = readFile(sFilename)
	size = len(employerMap)
	mux.Lock()
	for employer := range employerMap {
		go offer(employer)
	}
	mux.Unlock()
	evaluate()
	var fileName string = "matches_go_" + strconv.Itoa(size) + "x" + strconv.Itoa(size) + ".csv"
	writeFile(resultMap, fileName)
}
