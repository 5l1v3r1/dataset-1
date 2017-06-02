package dataset

import (
	"bytes"
	"encoding/csv"
	"encoding/json"
	"fmt"
	"io"
	"strconv"
	"strings"
	"text/template"

	// 3rd Party packages
	"github.com/blevesearch/bleve"
)

func JSONFormatter(out io.Writer, results *bleve.SearchResult) error {
	src, err := json.Marshal(results)
	if err != nil {
		return err
	}
	fmt.Fprintf(out, "%s\n", src)
	return nil
}

func CSVFormatter(out io.Writer, results *bleve.SearchResult, colNames []string) error {
	// Note: we need to provide the fieldnames that will be come columns
	w := csv.NewWriter(out)
	// write a header row
	if err := w.Write(colNames); err != nil {
		return err
	}
	for _, hit := range results.Hits {
		row := []string{}
		for _, col := range colNames {
			if val, ok := hit.Fields[col]; ok == true {
				switch val := val.(type) {
				case int:
					row = append(row, strconv.FormatInt(int64(val), 10))
				case uint:
					row = append(row, strconv.FormatUint(uint64(val), 10))
				case int64:
					row = append(row, strconv.FormatInt(val, 10))
				case uint64:
					row = append(row, strconv.FormatUint(val, 10))
				case float64:
					row = append(row, strconv.FormatFloat(val, 'G', -1, 64))
				case string:
					row = append(row, strings.TrimSpace(val))
				default:
					row = append(row, strings.TrimSpace(fmt.Sprintf("%s", val)))
				}
			} else {
				row = append(row, "")
			}
		}
		if err := w.Write(row); err != nil {
			return err
		}
	}
	w.Flush()
	if err := w.Error(); err != nil {
		return err
	}
	return nil
}

func HTMLFormatter(out io.Writer, results *bleve.SearchResult, tmpl *template.Template) error {
	src, err := json.Marshal(results)
	if err != nil {
		return err
	}
	data := map[string]interface{}{}
	decoder := json.NewDecoder(bytes.NewBuffer(src))
	decoder.UseNumber()
	if err := decoder.Decode(&data); err != nil {
		return err
	}
	return tmpl.Execute(out, data)
}