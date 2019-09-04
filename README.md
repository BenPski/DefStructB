# DefStructB

The implementation of the deformable structure using the b-links/space driven kinematics.

Depends on [MatlabUtils](https://github.com/BenPski/MatlabUtils).

# Model

This code is ment for modeling the behavior of structures that are made of both rigid components and soft joints. We look at a very specific kind of module and stacks of these modules. The modules have a top and bottom plate that are polygons with connection points at each corner. The links are attached to the connection points in an up-down pattern so that two links form a triangle with the base. For simplicity it is assumed the left or a-links are always rigid while the right or b-links can be rigid or soft with the stiffness being variable. It is assumed that the deformation is driven by a cable that runs through the center of both the upper and lower plates and you specify the displacement of the cable. Many of the components are idealized currently where there is no offsets in the connections and the joints are universal joints. 

To specify the geometry it is assumed that the plates are regular polygons and we need to specify the size of the polygon, number of sides, the overall height of the module, and the relative angle between the top and bottom polygons. We use the **r** to denote the radius of the polygon, or the distance from the center to a vertex, we use **N** to denote the number of sides, **&phi;** is the relative angle between the top and bottom plates, and we use **k** to define the ratio between the height of the module and the radius, **k=height/radius**. These specify the full geometry of the module and the refernce lengths of the links with the given simplifying assumptions. However, to fully define the module we need to specify the stiffness of the soft links. To leave it fairly general we specify an energy function that takes in the changes in length of the b-links and should compute the scalar energy.

All the classes are written in an immutable way so updating an object looks like `x = x.update()` where `update` is some method that changes the state of the object. This is important if you do a sequence of updates because if you just do `x.update()` repeatedly the state of `x` never actually changes from its original value.

# Single Module Example

As an exmple we first intitialize the module and then we can deform it and plot it.

```matlab
%simple parameters, stiffnesses all the same in the energy 
energy = @(b) b'*b;
r = 1;
k = 1;
N = 3;
phi = 0;

%initialize module
m = Module(r,k,N,phi,energy);
m.plot(); %plot the module

%Deform module slightly and plot again
m.step_energy(0.1).plot();
```
# Stacks of Modules

For stacks of modules we first have to initialize the modules we are going to use and then the stack can be initialized. The stack can then be used pretty much the same as the individual modules are.
```matlab
% initialize 2 modules that are the same (do not need to be the same)
m1 = Module(r,k,N,phi,energy);
m2 = Module(r,k,N,phi,energy);

%initialize stack
s = StackModules([m1,m2]);

%use like a module
s.plot()
s.step_energy(0.1).plot()
```

# Notes

Tried VP-trees for some applications in interpolating data, but it didn't work well. Could have been an implementation issue. Plan to just remove it.

Interpolation module works alright and is a bit more efficient for very repetitive tasks.

Still could generalize and add dynamics, but that should be done with a new project and approach.
