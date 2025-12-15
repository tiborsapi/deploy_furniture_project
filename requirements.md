# Functional Requirements

## 1. Handling Furniture Elements

- UR-0001: Selection and customization of elements
- Given: The user is on the selection interface.
- When: Selects a type (e.g., table leg), specifies dimensions (width, height) and quantity.
- Then: The element is added to the summary list.
- Acceptance Criteria: The system must store all specified parameters.

{FRONTEND} CR-0001 [UR: UR-0001]

- G: The user provided valid data.
- W: Clicks the "Add" button.
- T: The `selectedElements` list updates with the new object.
- BDT: { CR-0001, G: Input: 50x50 wood 2pcs, W: Click Add, T: List count increases by 1 }

## 2. Cutting Surface (Raw Material)

- UR-0002: Specifying cutting surface dimensions
- Given: The user is on the cutting interface.
- When: Enters the available cutting surface dimensions.
- Then: The system stores this size for cutting.
- Acceptance Criteria: The specified values can only be positive integers, and neither the width nor the height field can remain empty.

{FRONTEND} CR-0002 [UR: UR-0002]

- G: The "Sheet Size" field is filled.
- W: The user clicks the button.
- T: The system supplements the JSON with the specified dimensions.
- BDT: { CR-0002, G: Sheet input 2000x1000, W: Click button, T: Sheet size is 2000x1000 }

## 3. Communication and Feedback

- UR-0003 Name: Sending data and waiting
- Given: The user has compiled the list and set the cutting surface.
- When: Starts the optimization.
- Then: The system sends the data in JSON and shows a loading animation until the response arrives.
- Acceptance Criteria: The sent JSON includes the elements and the sheet size, the loading animation appears immediately, and loading disappears only after the server response.

{FRONTEND} CR-0003-A [UR: UR-0003]

- G: Parameters specified.
- W: The user clicks the "Optimize" button and the system initiates the HTTP request.
- T: The outgoing JSON body contains the selectedElements list and the sheetDimensions object.
- BDT: { CR-0003-A, G: List has 2 items, W: Click Optimize, T: Payload contains "sheetDimensions" and "selectedElements" }

{FRONTEND} CR-0003-B [UR: UR-0003]

- G: The HTTP request has started, but no response has arrived yet.
- W: The request status is "pending".
- T: The "Loading..." spinner is visible.
- BDT: { CR-0003-B, G: Network is slow, W: Request sent, T: Spinner visible }

## 4. Backend Optimization

- UR-0004 Name: Calculation of cutting plan
- Given: The Backend has received the elements and the sheet size.
- When: The algorithm runs.
- Then: The system calculates the exact X, Y position and rotation for every element to minimize waste.
- Acceptance Criteria: Elements must not overlap. Every element must be within the sheet boundaries (X + Width <= Sheet Width). All submitted elements must appear in the output.

{BACKEND} CR-0004 [UR: UR-0004]

- G: Valid input list received.
- W: The optimization logic runs.
- T: The response JSON contains `x`, `y`, and `rotation (new width and height)` fields for every element.
- BDT: { CR-0004, G: 2 items fit on sheet, W: Optimize, T: Items do not overlap }

## 5. Error Handling

- UR-0005 Name: Handling invalid data
- Given: The user sent incorrect data (e.g., missing dimension, specified surface too small) or the optimization failed.
- When: The Backend processes the request.
- Then: It sends back a detailed error message, which the Frontend displays.
- Acceptance Criteria: The HTTP status code should reflect the cause of the error.

{BACKEND} CR-0005 [UR: UR-0005]

- G: Width is missing from the incoming data.
- W: Validation runs.
- T: Response: 400 Bad Request, Message: "Missing width parameter".
- BDT: { CR-0005, G: Invalid Input, W: Send Request, T: Error message displayed }

## 6. Display (Rendering)

- UR-0006 Name: Visual display of results
- Given: Successful response (JSON) has arrived.
- When: The client processes the data.
- Then: The elements are drawn on the 2D interface based on the received coordinates.
- Acceptance Criteria: The full sheet border and the waste area are visible. The boundaries of the elements are clearly distinguishable.

{FRONTEND} CR-0006 [UR: UR-0006]

- G: JSON: `{x:10, y:10, w:100, h:50}`.
- W: Interface update.
- T: A rectangle appears at point (10,10).
- BDT: { CR-0006, G: Response received, W: Render, T: Elements appear on canvas }

## 7. Exporting

- UR-0007 Name: Saving plan as an image
- Given: The cutting plan is visible.
- When: The user chooses the export option.
- Then: The system generates an image file from the current view.
- Acceptance Criteria: The image contains the entire cutting area (even if scrolling is required on screen).

{FRONTEND} CR-0007 [UR: UR-0007]

- G: The drawing is ready.
- W: Pressing the "Export PNG" button.
- T: The browser downloads an image file.
- BDT: { CR-0007, G: Layout visible, W: Click Export, T: PNG file downloaded }
