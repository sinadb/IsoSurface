Implementation of isosurface extraction using marching cube algorithm with the help of mesh shaders and on Metal API.  User can enter an implicit function which is parsed from inFix to PostFix notation and then a pipeline is dynamically created using function stitching and pointers support of Metal API. User can select up to 3 iso levels to be displayed in fill/line modes with correct transparency visualised between overlapping iso levels. Below a few examples can be seen 



     f(x,y,z) = z^2 + 3z^2 - y^2

                                                                    
<img width="803" alt="Screenshot 2024-05-26 at 08 03 31" src="https://github.com/sinadb/isoSurface/assets/93264056/db875836-e336-4c38-ba03-4db21ccd89f2">
<img width="803" alt="Screenshot 2024-05-26 at 08 03 57" src="https://github.com/sinadb/isoSurface/assets/93264056/9e8c90dd-8922-40f9-8bb2-aa294b721de0">


    f(x,y,z) = x^4 + y^4 + z^4 - (x^2 + y^2 + z^2 - 0.4)

                                                                    
<img width="803" alt="Screenshot 2024-05-26 at 08 01 21" src="https://github.com/sinadb/isoSurface/assets/93264056/bb548385-d2f6-4f86-82d5-5130de8fd83c">
<img width="803" alt="Screenshot 2024-05-26 at 08 01 04" src="https://github.com/sinadb/isoSurface/assets/93264056/6158292f-ab49-40b1-a40c-25bcbe8c4372">


    f(x,y,z) = cos(x) + cos(y) + cos(z)

                                                                    
<img width="800" alt="Screenshot 2024-05-26 at 07 57 35" src="https://github.com/sinadb/isoSurface/assets/93264056/3638c789-f2b3-4ba9-a873-cc3e58efe613">
<img width="800" alt="Screenshot 2024-05-26 at 07 57 25" src="https://github.com/sinadb/isoSurface/assets/93264056/76f2e8eb-0066-492f-83fa-26b33e39f0b0">
