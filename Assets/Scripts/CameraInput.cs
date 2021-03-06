﻿using UnityEngine;

public class CameraInput : MonoBehaviour
{
    public enum RotationAxes { MouseXAndY = 0, MouseX = 1, MouseY = 2 }
    public RotationAxes axes = RotationAxes.MouseXAndY;
    public float sensitivityX = 15F;
    public float sensitivityY = 15F;

    public float minimumX = -360F;
    public float maximumX = 360F;

    public float minimumY = -60F;
    public float maximumY = 60F;

    public float MovementSpeed = 1.0f;

    float rotationY = 0F;

    void Update()
    {
		if (Cursor.lockState != CursorLockMode.Locked) {
			if (Input.GetMouseButtonDown(0)) {
				Cursor.visible = false;
				Cursor.lockState = CursorLockMode.Locked;
			}
			return;
		}
        if (axes == RotationAxes.MouseXAndY)
        {
            float rotationX = transform.localEulerAngles.y + Input.GetAxis("Mouse X") * sensitivityX;

            rotationY += Input.GetAxis("Mouse Y") * sensitivityY;
            rotationY = Mathf.Clamp(rotationY, minimumY, maximumY);

            transform.localEulerAngles = new Vector3(-rotationY, rotationX, 0);
        }
        else if (axes == RotationAxes.MouseX)
        {
            transform.Rotate(0, Input.GetAxis("Mouse X") * sensitivityX, 0);
        }
        else
        {
            rotationY += Input.GetAxis("Mouse Y") * sensitivityY;
            rotationY = Mathf.Clamp(rotationY, minimumY, maximumY);

            transform.localEulerAngles = new Vector3(-rotationY, transform.localEulerAngles.y, 0);
        }
        
        Vector3 input = new Vector3(Input.GetAxis("Horizontal"), Input.GetAxis("Strafe"), Input.GetAxis("Vertical"));
        transform.Translate(input * Time.deltaTime * MovementSpeed, Space.Self);
    }

    void Start()
    {
        // Make the rigid body not change rotation
        if (GetComponent<Rigidbody>())
        {
            GetComponent<Rigidbody>().freezeRotation = true;
        }

        Cursor.visible = false;
        Cursor.lockState = CursorLockMode.Locked;

    }
}