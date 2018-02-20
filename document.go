package dataset

// Document provides a common interface for ease of integration of Go structures with dataset operations
type Document interface {
	ToMAP() map[string]interface{}
}
