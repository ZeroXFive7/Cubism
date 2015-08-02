using UnityEngine;

public class SingletonMonobehaviour<T> : MonoBehaviour where T : MonoBehaviour
{
    private static T instance = null;
    public static T Instance
    {
        get
        {
            return instance;
        }
        protected set
        {
            if (instance == null)
            {
                instance = value;
            }
            else
            {
                Debug.LogError("Created more than one singleton of " + typeof(T).ToString() + "!");
            }
        }
    }
}
