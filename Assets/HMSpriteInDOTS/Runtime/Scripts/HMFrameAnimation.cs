using UnityEngine;


// ReSharper disable once CheckNamespace
namespace HM.HMSprite
{
    [RequireComponent(typeof(HMSprite))]
    public class HMFrameAnimation : MonoBehaviour
    {
        private HMSprite _hmSprite;
        public HMFrameAnimationSO hmFrameAnimationS0;

        [SerializeField, Range(0, 10f)] public float speed = 1;


        public float Progress
        {
            get => (_timer) / hmFrameAnimationS0.animationTotalTime;
            set { _timer = value * hmFrameAnimationS0.animationTotalTime; }
        }

        public int CurrentFrame
        {
            get =>
                hmFrameAnimationS0 == null || hmFrameAnimationS0.frameAnimation == null
                    ? -1
                    : Mathf.FloorToInt(
                        (Progress - Mathf.FloorToInt(Progress)) * hmFrameAnimationS0.frameAnimation.Count);
            set => Progress = value / (float)hmFrameAnimationS0.frameAnimation.Count;
        }

        private float _timer;
        public bool BePlaying { get; private set; }

        private void Awake()
        {
            _hmSprite = this.GetComponent<HMSprite>();
        }

        private void OnValidate()
        {
            if (_hmSprite == null)
            {
                _hmSprite = this.GetComponent<HMSprite>();
            }

            if (hmFrameAnimationS0 != null && hmFrameAnimationS0.frameAnimation.Count > 0)
            {
                _hmSprite.Sprite = hmFrameAnimationS0.frameAnimation[0];
                _hmSprite.OnValidate();
            }
        }

        private void Start()
        {
            if (hmFrameAnimationS0 != null && hmFrameAnimationS0.frameAnimation.Count > 0)
            {
                SetSprite(hmFrameAnimationS0.frameAnimation[CurrentFrame]);

                if (Application.isPlaying)
                {
                    BePlaying = true;
                }
            }
        }

        public void Play(int frame = 0, bool loop = false)
        {
            CurrentFrame = frame;

            BePlaying = true;
        }

        public void Stop()
        {
            BePlaying = false;
        }


        private void Update()
        {
            if (hmFrameAnimationS0 == null || hmFrameAnimationS0.frameAnimation.Count == 0)
            {
                BePlaying = false;
                return;
            }

            if (!BePlaying) return;

            _timer += (Time.deltaTime * speed * hmFrameAnimationS0.animationSpeed);
            if (_timer >= hmFrameAnimationS0.animationTotalTime)
            {
                if (!hmFrameAnimationS0.beLoop)
                {
                    Stop();
                    return;
                }
            }

            if (CurrentFrame >= 0)
            {
                SetSprite(hmFrameAnimationS0.frameAnimation[CurrentFrame]);
            }
        }

        private void SetSprite(Sprite sprite)
        {
            _hmSprite.Sprite = sprite;
        }
    }
}