#include "_lib.h"

namespace CTemplate {
	/**
	 * \defgroup CTemplate CTemplate: exemple c project
	 * @{
	 */

	/*! \brief Sum function.
	 * 
	 * return sum of A and B params.
	 * 
	 * @param a input first var.
	 * @param b input second var.
	 */
	CTemplateFunc int Sum(int a, int b);

	//! subtract b from a (shortbrief example)
	inline int Sub(int a, int b) { return a - b; }
	/**@}*/
}
//the comments above are DOXYGEN compatible documentation